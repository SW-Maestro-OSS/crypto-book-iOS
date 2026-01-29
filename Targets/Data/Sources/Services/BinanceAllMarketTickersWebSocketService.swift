//
//  BinanceAllMarketTickersWebSocketService.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity
import Domain

/// 모든 암호화폐의 시장가 정보를 실시간으로 받아오는 웹 소켓 서비스
final class BinanceAllMarketTickersWebSocketService: MarketTickerRemoteDataSource {

    private let urlSession: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    /// Create and own one instance of this service in your App/DI layer.
    /// (No singleton required.)
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func connect() -> AsyncThrowingStream<[MarketTickerDTO], Error> {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        return AsyncThrowingStream { continuation in
            do {
                let endpoint = BinanceEndpoint.allMarketTickers
                let url = try endpoint.asWebSocketURL()
                let task = urlSession.webSocketTask(with: url)
                task.resume()
                self.webSocketTask = task

                let decoder = JSONDecoder()
                let receiveTask = Task {
                    do {
                        while !Task.isCancelled {
                            let message = try await task.receive()
                            let data: Data
                            switch message {
                            case .data(let d): data = d
                            case .string(let t): data = Data(t.utf8)
                            @unknown default: continue
                            }
                            
                            do {
                                let dtos = try decoder.decode([MarketTickerDTO].self, from: data)
                                continuation.yield(dtos)
                            } catch {
                                print("Decoding Error: \(error)")
                            }
                        }
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }

                continuation.onTermination = { [weak self] _ in
                    receiveTask.cancel()
                    self?.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                    self?.webSocketTask = nil
                }
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
}
