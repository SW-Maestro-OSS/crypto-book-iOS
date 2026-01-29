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

enum MarketTickerClientKey: DependencyKey {
    static let liveValue: MarketTickerClient = {
        let useCase = Container.shared.subscribeMarketTickerUseCase()
        return MarketTickerClient(stream: { useCase.execute() })
    }()
}
