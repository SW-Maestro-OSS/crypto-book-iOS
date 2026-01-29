import Foundation
import ComposableArchitecture
import Factory
import Entity

// MARK: - Factory -> TCA Bridges

private let container = Container.shared

enum MarketTickerStreamClientKey: DependencyKey {
    static let liveValue: MarketTickerStreamClient = {
        let useCase = container.subscribeMarketTickerUseCase()
        return MarketTickerStreamClient(stream: { useCase.execute() })
    }()
}

enum KlineStreamClientKey: DependencyKey {
    static let liveValue: KlineStreamClient = {
        let useCase = container.subscribeCandleStickUseCase()
        return KlineStreamClient { symbol, interval in
            useCase.execute(symbol: symbol, interval: interval)
        }
    }()
}

enum FetchKlinesClientKey: DependencyKey {
    static let liveValue: FetchKlinesClient = {
        let useCase = container.fetchHistoricalCandlesticksUseCase()
        return FetchKlinesClient { symbol, interval, limit in
            try await useCase.execute(symbol: symbol, interval: interval, limit: limit)
        }
    }()
}

enum CurrencyDetailStreamClientKey: DependencyKey {
    static let liveValue: CurrencyDetailStreamClient = {
        let streaming = container.currencyDetailStreaming()
        return CurrencyDetailStreamClient(
            connect: { symbol in streaming.connect(symbol: symbol) },
            disconnect: { streaming.disconnect() }
        )
    }()
}

enum ExchangeRateClientKey: DependencyKey {
    static let liveValue: ExchangeRateClient = {
        let repo = container.exchangeRateRepository()
        return ExchangeRateClient(
            fetchUSDtoKRW: { try await repo.fetchUSDtoKRW() }
        )
    }()
}

// MARK: - DependencyValues

extension DependencyValues {
    var marketTickerStream: MarketTickerStreamClient {
        get { self[MarketTickerStreamClientKey.self] }
        set { self[MarketTickerStreamClientKey.self] = newValue }
    }

    var klineStream: KlineStreamClient {
        get { self[KlineStreamClientKey.self] }
        set { self[KlineStreamClientKey.self] = newValue }
    }

    var fetchKlines: FetchKlinesClient {
        get { self[FetchKlinesClientKey.self] }
        set { self[FetchKlinesClientKey.self] = newValue }
    }

    var currencyDetailStreaming: CurrencyDetailStreamClient {
        get { self[CurrencyDetailStreamClientKey.self] }
        set { self[CurrencyDetailStreamClientKey.self] = newValue }
    }

    var exchangeRateClient: ExchangeRateClient {
        get { self[ExchangeRateClientKey.self] }
        set { self[ExchangeRateClientKey.self] = newValue }
    }
}
