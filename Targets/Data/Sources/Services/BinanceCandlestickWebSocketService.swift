//
//  BinanceCandlestickWebSocketService.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Combine
import Entity

final class BinanceCandlestickStreamingWebSocketService {
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func connect(symbol: String, interval: String) -> AsyncThrowingStream<[OHLCV], Error> {
        // 바이낸스 웹소켓 URL 구조: wss://fstream.binance.com/ws/<symbol>@kline_<interval>
        let urlString = "wss://fstream.binance.com/ws/\(symbol.lowercased())@kline_\(interval)"
        guard let url = URL(string: urlString) else {
            return AsyncThrowingStream { $0.finish(throwing: URLError(.badURL)) }
        }
        
        let webSocket = session.webSocketTask(with: url)
        self.webSocket = webSocket
        webSocket.resume()
        
        return AsyncThrowingStream { continuation in
            func receiveMessage() {
                webSocket.receive { [weak self] result in
                    switch result {
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            if let data = text.data(using: .utf8) {
                                do {
                                    let decoder = JSONDecoder()
                                    let dto = try decoder.decode([BinanceKlineDTO].self, from: data)
                                    continuation.yield(dto.map{$0.toDomain() ?? OHLCV(openTimeMs: 0, open: 0, high: 0, low: 0, close: 0, volume: 0)})
                                } catch {
                                    // 디코딩 에러 처리
                                }
                            }
                        default:
                            break
                        }
                        receiveMessage()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }
            }
            
            receiveMessage()
            
            continuation.onTermination = { [weak self] _ in
                self?.disconnect()
            }
        }
    }
    
    public func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
}
