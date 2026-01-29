//
//  DependencyInjection.swift
//  CryptoBook
//
//  Created by 김정원 on 12/15/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Factory
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
    
    var subscribeCandleStickUseCase: Factory<SubscribeCandleStickStreamUseCase> {
        self {
            SubscribeCandleStickStreamUseCase(repository: self.candleStickStreamRepository())
        }
    }
    
    var fetchHistoricalCandlesticksUseCase: Factory<FetchHistoricalCandlesticksUseCase> {
        self {
            FetchHistoricalCandlesticksUseCase(repository: self.candlestickRepository())
        }
    }
        
    // MARK: - Repositories

    var marketTickerStreamRepository: Factory<any MarketTickerStreamRepository> {
        self { MarketTickerStreamRepositoryImpl(remoteDataSource: self.marketTickerStreamDataSource()) }
            .singleton
    }
    
    var candleStickStreamRepository: Factory<any CandleStickStreamRepository> {
        self { CandleStickStreamRepositoryImpl(remoteDataSource: self.klineStreamDataSource()) }
            .singleton
    }
    
    var candlestickRepository: Factory<any CandlestickRepository> {
        self { CandlestickRepositoryImpl(remoteDataSource: self.klineRemoteDataSource())}
    }

    var exchangeRateRepository: Factory<any ExchangeRateRepository> {
        self { ExchangeRateRepositoryImpl() }
            .singleton
    }
    
    // MARK: - DataSource
    var marketTickerStreamDataSource: Factory<any MarketTickerStreamDataSource> {
        self { MarketTickerStreamDataSourceImpl(wsClient: self.standardWebSocketClient())}
    }
    
    var klineStreamDataSource: Factory<any KlineStreamDataSource> {
        self { KlineStreamDataSourceImpl(wsClient: self.standardWebSocketClient())}
    }
    
    var klineRemoteDataSource: Factory<any BinanceKlineRemoteDataSource> {
        self { BinanceKlineRemoteDataSourceImpl(networkClient: self.networkClient())}
    }
    
    // MARK: - Services

    var currencyDetailStreaming: Factory<any CurrencyDetailStreaming> {
        self { CurrencyDetailStreamingImpl() }
    }
    
    // MARK: - Infra Service
    
    var standardWebSocketClient: Factory<any WebSocketClient> {
        self { StandardWebSocketClient() }
    }
    
    var networkClient: Factory<any NetworkClient> {
        self { URLSessionNetworkClient() } 
    }
    
}
