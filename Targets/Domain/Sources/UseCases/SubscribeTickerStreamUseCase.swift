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
    private let repository: KlineStreamRepository

    public init(repository: KlineStreamRepository) {
        self.repository = repository
    }

    public func execute(symbol: String, interval: String) -> AsyncThrowingStream<Candle, Error> {
        return repository.kLineStream(symbol: symbol, interval: interval)
    }
}

