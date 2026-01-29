//
//  FetchHistoricalCandlesticksUseCase.swift
//  Domain
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import Entity

public final class FetchHistoricalCandlesticksUseCase {
    private let repository: CandlestickRepository

    public init(repository: CandlestickRepository) {
        self.repository = repository
    }
    
    public func execute(symbol: String, interval: String, limit: Int) async throws -> [Candle] {
        try await repository.fetchKlines(symbol: symbol, interval: interval, limit: limit)
    }
}
