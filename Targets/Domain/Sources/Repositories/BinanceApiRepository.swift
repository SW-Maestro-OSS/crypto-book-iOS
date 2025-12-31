//
//  BinanceApiRepository.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public protocol BinanceApiRepository {
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [Candle]
}
