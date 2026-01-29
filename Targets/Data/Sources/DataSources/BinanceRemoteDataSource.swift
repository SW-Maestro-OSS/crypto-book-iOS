//
//  BinanceRemoteDataSource.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public protocol BinanceRemoteDataSource {
    /// 특정 심볼의 과거 캔들스틱(Kline) 데이터를 가져옵니다.
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [BinanceKlineRestDTO]
}
