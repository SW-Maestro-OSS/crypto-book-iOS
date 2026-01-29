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

    // MARK: - UseCases
    var subscribeMarketTickerUseCase: Factory<SubscribeMarketTickerUseCase> {
        self {
            SubscribeMarketTickerUseCase(repository: self.marketTickerStreamRepository())
        }
    }
    
    var subscribeKlineUseCase: Factory<SubscribeKlineStreamUseCase> {
        self {
            SubscribeKlineStreamUseCase(repository: self.klineStreamRepository())
        }
    }
    
    // MARK: - Repositories

    var marketTickerStreamRepository: Factory<any MarketTickerStreamRepository> {
        self { MarketTickerStreamRepositoryImpl(remoteDataSource: self.marketTickerStreamDataSource()) }
            .singleton
    }
    
    var klineStreamRepository: Factory<any KlineStreamRepository> {
        self { KlineStreamRepositoryImpl(remoteDataSource: self.candlestickStreamDataSource()) }
            .singleton
    }

    var exchangeRateRepository: Factory<any ExchangeRateRepository> {
        self { ExchangeRateRepositoryImpl() }
            .singleton
    }
    
    // MARK: - DataSource
    var marketTickerStreamDataSource: Factory<any MarketTickerStreamDataSource> {
        self { MarketTickerStreamDataSourceImpl(wsClient: self.standardWebSocketClient())}
    }
    
    var candlestickStreamDataSource: Factory<any KlineStreamDataSource> {
        self { KlineStreamDataSourceImpl(wsClient: self.standardWebSocketClient())}
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
    
    var standardWebSocketClient: Factory<any WebSocketClient> {
        self { StandardWebSocketClient() }
    }
    
    var networkClient: Factory<any NetworkClient> {
        self { URLSessionNetworkClient() } 
    }
    
    // MARK: - TCA clients (use these from DependencyKey liveValue)
    
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
