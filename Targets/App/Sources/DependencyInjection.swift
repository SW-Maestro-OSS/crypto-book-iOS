//
//  DependencyInjection.swift
//  CryptoBook
//
//  Created by 김정원 on 12/15/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Factory
import ComposableArchitecture
import Domain
import Data

extension Container {

    // MARK: - Domain ports

    var marketTickerStreaming: Factory<any MarketTickerStreaming> {
        self {
            Data.MarketTickerFactory.makeStreaming()
        }
        .singleton
    }

    // MARK: - TCA clients (use these from DependencyKey liveValue)

    var marketTickerClient: Factory<MarketTickerClient> {
        self {
            let streaming = self.marketTickerStreaming()
            return MarketTickerClient(
                stream: {
                    streaming.connect()
                }
            )
        }
    }
}
