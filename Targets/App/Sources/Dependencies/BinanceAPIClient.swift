//
//  BinanceAPIClient.swift
//  CryptoBook
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Factory
import Entity
import Data

struct BinanceAPIClient {
    var fetchKlines: @Sendable (_ symbol: String, _ interval: String, _ limit: Int) async throws -> [Candle]
    var streamKline: @Sendable (_ symbol: String, _ interval: String) -> AsyncThrowingStream<Candle, Error>
}

// MARK: - DependencyKey

extension BinanceAPIClient: DependencyKey {
    static let liveValue: Self = {
        @Injected(\.candlestickRepository) var repository
        let candlestickService = BinanceCandlestickStreamingWebSocketService()

        return Self(
            fetchKlines: { symbol, interval, limit in
                try await repository.fetchKlines(symbol: symbol, interval: interval, limit: limit)
            },
            streamKline: { symbol, interval in
                candlestickService.connect(symbol: symbol, interval: interval)
            }
        )
    }()
}

// MARK: - DependencyValues

extension DependencyValues {
    var binanceAPIClient: BinanceAPIClient {
        get { self[BinanceAPIClient.self] }
        set { self[BinanceAPIClient.self] = newValue }
    }
}
