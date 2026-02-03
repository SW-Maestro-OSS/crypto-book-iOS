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

@Reducer
struct CurrencyDetailFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let symbol: String
        let previousClosePrice: Double?

        // Shared State
        @Shared(.appStorage("exchangeRate")) var exchangeRate: Double = 0
        @Shared(.appStorage("selectedCurrency")) var selectedCurrency: CurrencyUnit = .usd

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

        init(
            symbol: String,
            previousClosePrice: Double?,
            priceChange24h: Double?,
            changePercent24h: Double?
        ) {
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
        case liveTickerUpdated(MarketTicker)
        case fetchChart
        case chartResponse(Result<[Candle], ChartError>)
        case candleUpdated(Candle)
        case fetchNews
        case newsResponse(Result<[NewsArticle], NewsError>)
        case computeInsight
        case insightComputed(Insight)
    }

    // MARK: - Errors

    enum ChartError: Error, Equatable {
        case network(String)
    }

    enum NewsError: Error, Equatable {
        case network(String)
    }

    enum CancelID {
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
    @Dependency(\.fetchKlines) var fetchKlines
    @Dependency(\.klineStream) var klineStream
    @Dependency(\.newsClient) var newsClient
    @Dependency(\.aiInsightClient) var aiInsightClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false

                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews)
                )

            case .onDisappear:
                return .none

            case let .liveTickerUpdated(ticker):
                state.midPrice = ticker.lastPrice
                state.priceChange24h = ticker.priceChange
                state.changePercent24h = ticker.priceChangePercent
                return .none

            // MARK: Chart
            case .fetchChart:
                state.chartLoading = true
                state.chartError = nil
                return .run { [symbol = state.symbol] send in
                    do {
                        let candles = try await fetchKlines.execute(symbol, "1d", 7)
                        await send(.chartResponse(.success(candles)))
                    } catch {
                        await send(.chartResponse(.failure(.network(error.localizedDescription))))
                    }
                }

            case let .chartResponse(.success(candles)):
                state.chartLoading = false
                state.candles = candles
                // Start kline streaming for real-time updates
                return .run { [symbol = state.symbol] send in
                    do {
                        for try await candle in klineStream.stream(symbol, "1d") {
                            await send(.candleUpdated(candle))
                        }
                    } catch {
                        // Swallow streaming errors
                    }
                }
                .cancellable(id: CancelID.klineSocket, cancelInFlight: true)

            case let .chartResponse(.failure(error)):
                state.chartLoading = false
                state.chartError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            case let .candleUpdated(candle):
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

                // Cryptopanic API expects currency code without USDT suffix (e.g., "BTC" not "BTCUSDT")
                let currency = state.symbol.replacingOccurrences(of: "USDT", with: "")
                print("[News] Fetching news for currency: \(currency)")
                return .run { send in
                    do {
                        let articles = try await newsClient.fetchNews(currency)
                        print("[News] Fetched \(articles.count) articles")
                        await send(.newsResponse(.success(articles)))
                    } catch {
                        print("[News] Error fetching news: \(error)")
                        await send(.newsResponse(.failure(.network(error.localizedDescription))))
                    }
                }

            case let .newsResponse(.success(items)):
                state.newsLoading = false
                state.news = items
                print("[News] Response success: \(items.count) items stored")
                return .send(.computeInsight)

            case let .newsResponse(.failure(error)):
                state.newsLoading = false
                print("[News] Response failure: \(error)")
                state.newsError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            // MARK: Insight
            case .computeInsight:
                // Skip if already has insight or still loading data
                guard state.insight == nil else { return .none }

                state.insightLoading = true
                print("[AI] Computing insight for \(state.symbol)...")

                return .run { [symbol = state.symbol, candles = state.candles, news = state.news] send in
                    do {
                        let result = try await aiInsightClient.generateInsight(symbol, candles, news)
                        print("[AI] Insight generated successfully")
                        let insight = Insight(
                            buyPercent: result.buyPercent,
                            sellPercent: result.sellPercent,
                            bullets: result.bullets
                        )
                        await send(.insightComputed(insight))
                    } catch {
                        print("[AI] Error generating insight: \(error)")
                        // Fallback to placeholder
                        let fallback = makeFallbackInsight(symbol: symbol, candles: candles, news: news)
                        await send(.insightComputed(fallback))
                    }
                }

            case let .insightComputed(insight):
                state.insightLoading = false
                state.insight = insight
                return .none
            }
        }
    }

}

// MARK: - Helpers

private func makeFallbackInsight(
    symbol: String,
    candles: [Candle],
    news: [NewsArticle]
) -> CurrencyDetailFeature.Insight {
    let currency = symbol.replacingOccurrences(of: "USDT", with: "")
    var buy = 50
    var sell = 50

    if let first = candles.first, let last = candles.last {
        if last.close > first.open {
            buy = 60
            sell = 40
        } else if last.close < first.open {
            buy = 40
            sell = 60
        }
    }

    var bullets: [String] = []

    // 뉴스 헤드라인 요약
    if !news.isEmpty {
        let topNews = news.prefix(3)
        for article in topNews {
            let shortTitle = article.title.count > 50
                ? String(article.title.prefix(50)) + "..."
                : article.title
            bullets.append(shortTitle)
        }
    }

    // 차트 추세
    if let first = candles.first, let last = candles.last {
        let change = ((last.close - first.open) / first.open) * 100
        let trend = change >= 0 ? "상승" : "하락"
        bullets.append("\(currency) 7일간 \(String(format: "%.1f", abs(change)))% \(trend) 추세")
    }

    if bullets.isEmpty {
        bullets.append("데이터를 불러오는 중입니다.")
    }

    return CurrencyDetailFeature.Insight(buyPercent: buy, sellPercent: sell, bullets: bullets)
}
