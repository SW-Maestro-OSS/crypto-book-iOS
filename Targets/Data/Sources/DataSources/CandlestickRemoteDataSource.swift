//
//  CandlestickRemoteDataSource.swift
//  Data
//

import Foundation

public protocol CandlestickRemoteDataSource {
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceKlineRestDTO]
}
