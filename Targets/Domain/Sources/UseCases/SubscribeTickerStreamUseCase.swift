//
//  SubscribeTickerStreamUseCase.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import Entity

public final class SubscribeKlineStreamUseCase {
    private let repository: MarketTickerStreamRepository

    public init(repository: MarketTickerStreamRepository) {
        self.repository = repository
    }

    public func execute() -> AsyncThrowingStream<[MarketTicker], Error> {
        return repository.tickerStream()
    }
}

