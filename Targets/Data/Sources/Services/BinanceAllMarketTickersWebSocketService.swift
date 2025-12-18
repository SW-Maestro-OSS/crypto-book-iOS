//
//  BinanceAllMarketTickersWebSocketService.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

// Data/Sources/Market/BinanceAllMarketTickersWebSocketService.swift
import Foundation
import Entity
import Domain

final class BinanceAllMarketTickersWebSocketService: MarketTickerStreaming {

    private let urlSession: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = URL(string: "wss://fstream.binance.com")!

    /// Create and own one instance of this service in your App/DI layer.
    /// (No singleton required.)
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func connect() -> AsyncThrowingStream<[MarketTicker], Error> {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        let url = baseURL.appending(path: "/ws/!ticker@arr")
        let task = urlSession.webSocketTask(with: url)
        task.resume()
        self.webSocketTask = task

        return AsyncThrowingStream { continuation in
            func receiveNext() {
                task.receive { result in
                    switch result {
                    case .failure(let error):
                        continuation.finish(throwing: error)

                    case .success(let message):
                        do {
                            let data: Data
                            switch message {
                            case .data(let d): data = d
                            case .string(let t): data = Data(t.utf8)
                            @unknown default:
                                receiveNext()
                                return
                            }

                            let dtos = try JSONDecoder()
                                .decode([MarketTickerDTO].self, from: data)
                            continuation.yield(dtos.map { $0.toDomain() })
                            receiveNext()
                        } catch {
                            receiveNext()
                        }
                    }
                }
            }

            receiveNext()

            continuation.onTermination = { [weak self] _ in
                self?.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                self?.webSocketTask = nil
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
}
