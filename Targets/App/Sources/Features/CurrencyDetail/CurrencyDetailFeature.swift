//
//  CurrencyDetailFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Entity
import Domain

@Reducer
struct CurrencyDetailFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let symbol: String
        let previousClosePrice: Double?

        // Header (live-ish)
        var midPrice: Double?
        var priceChange24h: Double?
        var changePercent24h: Double?

        // Chart (snapshot)
        var candles: [Candle] = []
        var chartLoading: Bool = false
        var chartError: String?

        // AI Insight (placeholder)
        var insight: Insight?
        var insightLoading: Bool = false

        // News
        var news: [NewsArticle] = []
        var newsLoading: Bool = false
        var newsError: String?

        // View
        var isFirstAppear: Bool = true

        init(symbol: String, previousClosePrice: Double?, priceChange24h: Double?, changePercent24h: Double?) {
            self.symbol = symbol
            self.previousClosePrice = previousClosePrice
            self.priceChange24h = priceChange24h
            self.changePercent24h = changePercent24h
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case onDisappear
        case tickReceived(CurrencyDetailTick)
        case fetchChart
        case chartResponse(Result<[Candle], ChartError>)
        case candleUpdated(Result<Candle, Error>)
        case fetchNews
        case newsResponse(Result<[NewsArticle], NewsError>)
        case computeInsight
        case insightComputed(Insight)
        case newsItemTapped(NewsArticle)
    }

    // MARK: - Errors

    enum ChartError: Error, Equatable {
        case network(String)
    }

    enum NewsError: Error, Equatable {
        case network(String)
    }

    enum CancelID {
        case detailSocket
        case klineSocket
    }

    // MARK: - Models

    struct Insight: Equatable {
        let buyPercent: Int
        let sellPercent: Int
        let bullets: [String]

        init(buyPercent: Int, sellPercent: Int, bullets: [String]) {
            self.buyPercent = buyPercent
            self.sellPercent = sellPercent
            self.bullets = bullets
        }
    }

    // MARK: - Reducer
    @Dependency(\.currencyDetailStreaming) var streaming
    @Dependency(\.binanceAPIClient) var binanceAPIClient

    init() {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false

                // Kick off snapshot fetches.
                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews),
                    .send(.computeInsight),
                    .run { [symbol = state.symbol] send in
                        defer { streaming.disconnect() }
                        do {
                            for try await tick in streaming.connect(symbol) {
                                await send(.tickReceived(tick))
                            }
                        } catch {
                            // Swallow streaming errors for now; UI can stay on last known values.
                        }
                    }
                    .cancellable(id: CancelID.detailSocket, cancelInFlight: true)
                )

            case .onDisappear:
                return .none

            // MARK: Live header updates
            case let .midPriceUpdated(value):
                state.midPrice = value
                state.lastUpdated = Date()
                return .none

            case let .changePercent24hUpdated(value):
                state.changePercent24h = value
                state.lastUpdated = Date()
                return .none

            case let .tickReceived(tick):
                if let mid = tick.midPrice {
                    state.midPrice = mid
                    // Recalculate absolute change based on the new mid-price
                    if let prevClose = state.previousClosePrice {
                        state.priceChange24h = mid - prevClose
                    }
                }
                if let change = tick.changePercent24h {
                    state.changePercent24h = change
                }
                return .none

            // MARK: Chart
            case .fetchChart:
                state.chartLoading = true
                state.chartError = nil
                return .run { [symbol = state.symbol] send in
                    do {
                        let candles = try await binanceAPIClient.fetchKlines(symbol, "1d", 7)
                        await send(.chartResponse(.success(candles)))
                    } catch {
                        await send(.chartResponse(.failure(.network(error.localizedDescription))))
                    }
                }

            case let .chartResponse(.success(candles)):
                state.chartLoading = false
                state.candles = candles
                // Start kline streaming for real-time updates
                return .merge(
                    .send(.computeInsight),
                    .run { [symbol = state.symbol] send in
                        defer { binanceAPIClient.disconnectKlineStream() }
                        do {
                            for try await candle in binanceAPIClient.streamKline(symbol, "1d") {
                                await send(.candleUpdated(candle))
                            }
                        } catch {
                            // Swallow streaming errors
                        }
                    }
                    .cancellable(id: CancelID.klineSocket, cancelInFlight: true)
                )

            case let .chartResponse(.failure(error)):
                state.chartLoading = false
                state.chartError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            case let .candleUpdated(candle):
                print("🕯️ Candle Updated: \(candle)")
                guard !state.candles.isEmpty else { return .none }

                let calendar = Calendar.current
                if let lastCandle = state.candles.last,
                   calendar.isDate(
                    Date(timeIntervalSince1970: TimeInterval(lastCandle.openTimeMs) / 1000),
                    inSameDayAs: Date(timeIntervalSince1970: TimeInterval(candle.openTimeMs) / 1000)
                   ) {
                    // It's an update for the last candle (today).
                    state.candles[state.candles.count - 1] = candle
                } else if let lastCandle = state.candles.last, candle.openTimeMs > lastCandle.openTimeMs {
                    // A new day's candle has arrived.
                    state.candles.append(candle)
                    if state.candles.count > 7 {
                        state.candles.removeFirst()
                    }
                }
                return .none

            // MARK: News
            case .fetchNews:
                state.newsLoading = true
                state.newsError = nil

                // TODO: Replace with real CryptoPanic fetch
                return .send(.newsResponse(.success([])))

            case let .newsResponse(.success(items)):
                state.newsLoading = false
                state.news = items
                return .send(.computeInsight)

            case let .newsResponse(.failure(error)):
                state.newsLoading = false
                state.newsError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            // MARK: Insight
            case .computeInsight:
                // Very small rule-based placeholder:
                state.insightLoading = true

                let insight = Self.makePlaceholderInsight(
                    symbol: state.symbol,
                    candles: state.candles,
                    news: state.news
                )
                return .send(.insightComputed(insight))

            case let .insightComputed(insight):
                state.insightLoading = false
                state.insight = insight
                return .none

            

            case .newsItemTapped:
                // The View should handle opening the URL (system browser).
                return .none
            }
        }
    }

    // MARK: - Helpers

    static func makePlaceholderInsight(
        symbol: String,
        candles: [Candle],
        news: [NewsArticle]
    ) -> Insight {
        var buy = 50
        var sell = 50

        if let first = candles.first, let last = candles.last {
            if last.close > first.open {
                buy = 70
                sell = 30
            } else if last.close < first.open {
                buy = 30
                sell = 70
            }
        }

        var bullets: [String] = []
        bullets.append("현재 \(symbol)의 추세를 기반으로 한 간단 분석입니다.")

        if !candles.isEmpty {
            bullets.append("최근 7일(1D) 캔들 흐름을 반영했습니다.")
        }

        if !news.isEmpty {
            bullets.append("관련 뉴스 신호를 함께 고려했습니다.")
        } else {
            bullets.append("현재는 뉴스 데이터가 없어 차트 중심으로 판단합니다.")
        }

        return Insight(buyPercent: buy, sellPercent: sell, bullets: bullets)
    }
}
