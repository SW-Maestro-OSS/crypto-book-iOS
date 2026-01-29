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
import Infra

extension Container {

    // MARK: - Repositories

    var marketTickerRepository: Factory<any MarketTickerRepository> {
        self { MarketTickerRepositoryImpl(remoteDataSource: self.marketTickerRemoteDataSource()) }
            .singleton
    }

    var exchangeRateRepository: Factory<any ExchangeRateRepository> {
        self { ExchangeRateRepositoryImpl() }
            .singleton
    }
    
    // MARK: - DataSource
    var marketTickerRemoteDataSource: Factory<any MarketTickerRemoteDataSource> {
        self { MarketTickerRemoteDataSourceImpl(wsClient: self.binanceAllMarketTickersWebSocketService())}
    }
    
    var candlestickRemoteDataSource: Factory<any CandlestickRemoteDataSource> {
        self { BinanceCandlestickRemoteDataSourceImpl(networkClient: self.networkClient())}
    }
    
    // MARK: - Services

    var currencyDetailStreaming: Factory<any CurrencyDetailStreaming> {
        self { CurrencyDetailStreamingImpl() }
    }

    var candlestickRepository: Factory<any CandlestickRepository> {
        self { CandlestickRepositoryImpl(remoteDataSource: self.candlestickRemoteDataSource())}
            .singleton
    }
    
    // MARK: - Infra Service
    
    var binanceAllMarketTickersWebSocketService: Factory<any WebSocketClient> {
        self { BinanceAllMarketTickersWebSocketService() }
            .singleton
    }
    
    var networkClient: Factory<any NetworkClient> {
        self { URLSessionNetworkClient() } 
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
                    try await self.candlestickRepository().fetchKlines(
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

    var exchangeRateClient: Factory<ExchangeRateClient> {
        self {
            ExchangeRateClient(
                fetchUSDtoKRW: {
                    try await self.exchangeRateRepository().fetchUSDtoKRW()
                }
            )
        }
    }
}
