//
//  BinanceCurrencyDetailWebSocketService.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//

import Foundation
import Domain
/// 특정 암호화폐의 상세정보를 실시간으로 받아옴
final class BinanceCurrencyDetailWebSocketService: CurrencyDetailRemoteDataSource, @unchecked Sendable {

    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Connects to Binance WS for a single symbol and emits `CurrencyDetailTick`.
    func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error> {
        let lower = symbol.lowercased()

        // bookTicker (mid price) + 24hr ticker (change percent)
        let streams = "\(lower)@bookTicker/\(lower)@ticker"
        let urlString = "wss://stream.binance.com:9443/stream?streams=\(streams)"
        let url = URL(string: urlString)!

        // Cancel any existing connection (screen re-appear)
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        let task = session.webSocketTask(with: url)
        self.webSocketTask = task
        task.resume()

        return AsyncThrowingStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

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
                            case .string(let s): data = Data(s.utf8)
                            @unknown default:
                                receiveNext()
                                return
                            }

                            if let tick = try self.parseTick(from: data) {
                                continuation.yield(tick)
                            }
                            receiveNext()
                        } catch {
                            continuation.finish(throwing: error)
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

// MARK: - Parsing
private extension BinanceCurrencyDetailWebSocketService {

    struct StreamEnvelope<T: Decodable>: Decodable {
        let stream: String
        let data: T
    }

    struct BookTickerDTO: Decodable {
        let s: String      // symbol
        let b: String      // best bid price
        let a: String      // best ask price
    }

    struct Ticker24hDTO: Decodable {
        let s: String      // symbol
        let P: String      // price change percent
    }

    func parseTick(from data: Data) throws -> CurrencyDetailTick? {
        // Try bookTicker first
        if let envelope = try? JSONDecoder().decode(StreamEnvelope<BookTickerDTO>.self, from: data) {
            let bid = Double(envelope.data.b)
            let ask = Double(envelope.data.a)
            let mid = (bid != nil && ask != nil) ? ((bid! + ask!) / 2.0) : nil

            return CurrencyDetailTick(
                symbol: envelope.data.s,
                midPrice: mid,
                changePercent24h: nil
            )
        }

        // Then try 24h ticker
        if let envelope = try? JSONDecoder().decode(StreamEnvelope<Ticker24hDTO>.self, from: data) {
            let change = Double(envelope.data.P)

            return CurrencyDetailTick(
                symbol: envelope.data.s,
                midPrice: nil,
                changePercent24h: change
            )
        }

        return nil
    }
}
