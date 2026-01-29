//
//  MarketTickerUseCase.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import Entity

public final class SubscribeMarketTickerUseCase {
    private let repository: MarketTickerRepository

    public init(repository: MarketTickerRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncThrowingStream<[MarketTicker], Error> {
        return repository.tickerStream()
    }
}
