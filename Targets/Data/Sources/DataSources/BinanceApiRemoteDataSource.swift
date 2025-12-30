//
//  BinanceApiRemoteDataSource.swift
//  Data
//

import Foundation

protocol BinanceApiRemoteDataSource {
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceKlineRestDTO]
}
