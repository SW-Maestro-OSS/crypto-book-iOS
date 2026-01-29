//
//  CandlestickRemoteDataSource.swift
//  Data
//

import Foundation

public protocol BinanceKlineRemoteDataSource {
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceHistoricalKlineDTO]
}
