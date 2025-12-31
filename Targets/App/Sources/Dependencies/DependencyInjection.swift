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
        self { MarketTickerRepositoryImpl() }
            .singleton
    }

    // MARK: - Services

    var currencyDetailStreaming: Factory<any CurrencyDetailStreaming> {
        self { CurrencyDetailStreamingImpl() }
    }

    var binanceApiRepository: Factory<any BinanceApiRepository> {
        self { BinanceApiRepositoryImpl() }.singleton
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
    
    var candlestickStreaming: Factory<BinanceCandlestickStreamingWebSocketService> {
        self { BinanceCandlestickStreamingWebSocketService() }
    }

    var binanceAPIClient: Factory<BinanceAPIClient> {
        self {
            let candlestickService = self.candlestickStreaming()
            return BinanceAPIClient(
                fetchKlines: { symbol, interval, limit in
                    try await self.binanceApiRepository().fetchKlines(
                        symbol: symbol,
                        interval: interval,
                        limit: limit
                    )
                },
                streamKline: { symbol, interval in
                    candlestickService.connect(symbol: symbol, interval: interval)
                },
                disconnectKlineStream: {
                    candlestickService.disconnect()
                }
            )
        }
    }
}
