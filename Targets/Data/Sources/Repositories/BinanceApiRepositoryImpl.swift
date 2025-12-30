//
//  BinanceApiRepositoryImpl.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain
import Entity

public final class BinanceApiRepositoryImpl: BinanceApiRepository {
    private let remoteDataSource: BinanceApiRemoteDataSource

    public init() {
        self.remoteDataSource = BinanceApiService()
    }

    init(remoteDataSource: BinanceApiRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [OHLCV] {
        let dtos = try await remoteDataSource.fetchKlines(
            symbol: symbol,
            interval: interval,
            limit: limit
        )
        return dtos.compactMap { $0.toDomain() }
    }
}
