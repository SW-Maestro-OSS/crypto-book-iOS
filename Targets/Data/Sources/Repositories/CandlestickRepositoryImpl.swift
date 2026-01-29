//
//  BinanceApiRepositoryImpl.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

//import Foundation
//import Domain
//import Entity
//
//public final class CandlestickRepositoryImpl: CandlestickRepository {
//    private let remoteDataSource: CandlestickRemoteDataSource
//
//    public init(remoteDataSource: CandlestickRemoteDataSource) {
//        self.remoteDataSource = remoteDataSource
//    }
//
//    public func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [Candle] {
//        let dtos = try await remoteDataSource.fetchKlines(
//            symbol: symbol,
//            interval: interval,
//            limit: limit
//        )
//        return dtos.compactMap { $0.toDomain() }
//    }
//}
