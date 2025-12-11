//
//  BinanceAllMarketTickersWebSocketService.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain

/// Binance USDⓈ-M Futures All Market Tickers WebSocket 서비스
/// 문서: https://developers.binance.com/docs/derivatives/usds-margined-futures/websocket-market-streams/All-Market-Tickers-Streams
final class BinanceAllMarketTickersWebSocketService {

    private let urlSession: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    // Binance USDS-M Futures base url
    private let baseURL = URL(string: "wss://fstream.binance.com")!

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func connect() -> AsyncThrowingStream<[MarketTicker], Error> {
        // 이미 연결 중이면 기존 스트림은 끊고 새로 연결
        webSocketTask?.cancel(with: .goingAway, reason: nil)

        let url = baseURL.appending(path: "/ws/!ticker@arr")
        let task = urlSession.webSocketTask(with: url)
        task.resume()
        self.webSocketTask = task

        return AsyncThrowingStream { continuation in
            // 수신 루프
            func receiveNext() {
                task.receive { result in
                    switch result {
                    case .failure(let error):
                        continuation.finish(throwing: error)

                    case .success(let message):
                        do {
                            let data: Data

                            switch message {
                            case .data(let d):
                                data = d
                            case .string(let text):
                                data = Data(text.utf8)
                            @unknown default:
                                // 알 수 없는 메시지 타입 -> 그냥 다음 메시지 요청
                                receiveNext()
                                return
                            }

                            // payload는 [TickerDTO] 배열 형태
                            let decoder = JSONDecoder()
                            let dtos = try decoder.decode([MarketTickerDTO].self, from: data)
                            let tickers = dtos.map { $0.toDomain() }

                            continuation.yield(tickers)

                            // 다음 메시지 수신
                            receiveNext()
                        } catch {
                            // 디코딩 에러는 스트림을 끊지 않고, 그냥 스킵하고 다음 메시지 읽기
                            // 필요하면 로그만 찍고 진행
                            print("⚠️ WebSocket decode error:", error)
                            receiveNext()
                        }
                    }
                }
            }

            receiveNext()

            continuation.onTermination = { [weak self] _ in
                self?.webSocketTask?.cancel(with: .goingAway, reason: nil)
                self?.webSocketTask = nil
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
}
