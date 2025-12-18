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

    // MARK: - Repositories

    var marketTickerRepository: Factory<any MarketTickerRepository> {
        self { DataFactory.makeMarketTickerRepository() }
            .singleton
    }
    
    // MARK: - Services

    var currencyDetailStreaming: Factory<any CurrencyDetailStreaming> {
        self { DataFactory.makeCurrencyDetailStreaming() }
    }
    
    var binanceApiRepository: Factory<any BinanceApiRepository> {
        self { DataFactory.fetchBinanceApi() }.singleton
    }
    
    // MARK: - TCA clients (use these from DependencyKey liveValue)
    
    var marketTickerClient: Factory<MarketTickerClient> {
        self {
            return MarketTickerClient(
                stream: {
                    self.marketTickerRepository().tickerStream()
                }
            )
        }
    }
    
    var currencyDetailStreamingClient: Factory<CurrencyDetailStreamingClient> {
        self {
            CurrencyDetailStreamingClient(
                connect: { symbol in
                    self.currencyDetailStreaming().connect(symbol: symbol)
                },
                disconnect: {
                    self.currencyDetailStreaming().disconnect()
                }
            )
        }
    }
    
    var binanceAPIClient: Factory<BinanceAPIClient> {
        self {
            BinanceAPIClient(
                fetchKlines: { symbol, interval, limit in
                    // Container에 등록된 repository를 호출
                    try await self.binanceApiRepository().fetchKlines(
                        symbol: symbol,
                        interval: interval,
                        limit: limit
                    )
                }
            )
        }
    }
}
