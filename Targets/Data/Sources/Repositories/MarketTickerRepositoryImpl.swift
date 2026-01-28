//
//  InitialDataRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity
import Domain

public final class MarketTickerRepositoryImpl: MarketTickerRepository {
    private let remoteDataSource: MarketTickerRemoteDataSource

    public init() {
        self.remoteDataSource = BinanceAllMarketTickersWebSocketService()
    }

    init(remoteDataSource: MarketTickerRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func tickerStream() -> AsyncThrowingStream<[MarketTicker], Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do { let dtoStream = remoteDataSource.connect()
                    
                    for try await dtos in dtoStream {
                        let tickers = dtos.map{$0.toDomain()}
                        continuation.yield(tickers)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
