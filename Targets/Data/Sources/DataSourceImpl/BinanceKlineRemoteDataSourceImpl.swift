//
//  BinanceRemoteDataSourceImpl.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public final class BinanceKlineRemoteDataSourceImpl: BinanceKlineRemoteDataSource {
    private let networkClient: NetworkClient // 인프라 주입
    private let decoder = JSONDecoder()

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceHistoricalKlineDTO] {
        let endpoint = BinanceEndpoint.klines(symbol: symbol, interval: interval, limit: limit)
        // 인프라를 통해 Data를 받아옴
        let data = try await networkClient.request(endpoint: endpoint)
        // 여기서 DTO로 변환
        return try decoder.decode([BinanceHistoricalKlineDTO].self, from: data)
    }
}
