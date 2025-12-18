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

struct BinanceAPIClient {
    var fetchKlines: @Sendable (_ symbol: String, _ interval: String, _ limit: Int) async throws -> [OHLCV]
}

// MARK: - DependencyKey

extension BinanceAPIClient: DependencyKey {
    static let liveValue: Self = {
        @Injected(\.binanceApiRepository) var repository
        
        return Self(
            fetchKlines: { symbol, interval, limit in
                try await repository.fetchKlines(symbol: symbol, interval: interval, limit: limit)
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
