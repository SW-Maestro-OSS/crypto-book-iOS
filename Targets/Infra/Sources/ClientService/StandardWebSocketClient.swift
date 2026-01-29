//
//  BinanceAllMarketTickersWebSocketService.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Data

/// 모든 암호화폐의 시장가 정보를 실시간으로 받아오는 웹 소켓 서비스
public final class StandardWebSocketClient: WebSocketClient {
    private let urlSession: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    // ✅ 변경: URL을 외부에서 주입받고, Data 스트림을 반환합니다.
    public func connect(url: URL) -> AsyncThrowingStream<Data, Error> {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        let task = urlSession.webSocketTask(with: url)
        task.resume()
        self.webSocketTask = task

        return AsyncThrowingStream { continuation in
            let receiveTask = Task {
                do {
                    while !Task.isCancelled {
                        let message = try await task.receive()
                        switch message {
                        case .data(let data):
                            continuation.yield(data)
                        case .string(let text):
                            if let data = text.data(using: .utf8) {
                                continuation.yield(data)
                            }
                        @unknown default:
                            continue
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
        }
    }

    public func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
}
