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

final class BinanceApiRepositoryImpl: BinanceApiRepository {
    private let apiService: BinanceApiService // 위에서 만드신 서비스
    
    init(apiService: BinanceApiService = BinanceApiService()) {
        self.apiService = apiService
    }
    
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [OHLCV] {
        // 1. 서비스를 통해 DTO 배열을 받아옵니다.
        let dtos = try await apiService.fetchKlines(
            symbol: symbol,
            interval: interval,
            limit: limit
        )
        return dtos.compactMap { $0.toDomain() }
    }
}
