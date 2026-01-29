//
//  BinanceApiService.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Combine

/// 과거 차트의 양봉 데이터를 받아오기 위한 서비스
final class BinanceApiService: BinanceApiRemoteDataSource {
    private let session = URLSession.shared
    
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceKlineRestDTO] {
        let endpoint = BinanceEndpoint.klines(symbol: symbol, interval: interval, limit: limit)
        let request = try endpoint.asURLRequest()
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        // 바이낸스 REST API 응답은 단순 2차원 배열 형태이므로 커스텀 디코딩이 필요할 수 있습니다.
        return try JSONDecoder().decode([BinanceKlineRestDTO].self, from: data)
    }
}
