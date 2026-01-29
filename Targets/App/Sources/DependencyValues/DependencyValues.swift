//
//  DependencyValues.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture 
// MARK: - DependencyValues

extension DependencyValues {
    var marketTicker: MarketTickerClient {
        get { self[MarketTickerClientKey.self] }
        set { self[MarketTickerClientKey.self] = newValue }
    }
}
