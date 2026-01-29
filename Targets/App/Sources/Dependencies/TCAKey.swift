//
//  TCAKey.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Factory

enum MarketTickerStreamClientKey: DependencyKey {
    static let liveValue: MarketTickerStreamClient = {
        let useCase = Container.shared.subscribeMarketTickerUseCase()
        return MarketTickerStreamClient(stream: { useCase.execute() })
    }()
}

enum KlineStreamClientKey: DependencyKey {
    static let liveValue: KlineStreamClient = {
        let useCase = Container.shared.subscribeKlineUseCase()
        return KlineStreamClient { symbol, interval in
            useCase.execute(symbol: symbol, interval: interval)
        }
    }()
}
