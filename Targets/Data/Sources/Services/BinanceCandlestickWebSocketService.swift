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

/// 특정 암호화폐의 양봉 정보를 실시간으로 받아옴
public final class BinanceCandlestickStreamingWebSocketService: CandlestickRemoteDataSource2 {
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func connect(symbol: String, interval: String) -> AsyncThrowingStream<Candle, Error> {
        return AsyncThrowingStream { continuation in
            do {
                let endpoint = BinanceEndpoint.candlestick(symbol: symbol, interval: interval)
                let url = try endpoint.asWebSocketURL()
                
                let webSocket = session.webSocketTask(with: url)
                self.webSocket = webSocket
                webSocket.resume()

                func receiveMessage() {
                    webSocket.receive { [weak self] result in
                        switch result {
                        case .success(let message):
                            switch message {
                            case .string(let text):
                                if let data = text.data(using: .utf8) {
                                    do {
                                        let decoder = JSONDecoder()
                                        let dto = try decoder.decode(BinanceKlineDTO.self, from: data)
                                        if let candle = dto.toDomain() {
                                            continuation.yield(candle)
                                        }
                                    } catch {
                                        // Decoding error - skip this message
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
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
    
    public func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
}
