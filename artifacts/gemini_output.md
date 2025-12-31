# `Equatable` 준수 오류 수정

`CurrencyDetailFeature.Action`이 `Equatable` 프로토콜을 준수하지 못해 발생한 컴파일 오류들을 해결합니다.

**문제 원인:**
`candleUpdated` 액션의 연관 값으로 `Result<Candle, Error>`를 사용했습니다. `Error` 타입은 `Equatable`이 아니므로, `Action` 열거형 전체가 `Equatable` 규칙을 위반하게 되어 연쇄적인 컴파일 오류가 발생했습니다.

**해결책:**
- `candleUpdated` 액션이 `Result` 대신 `Candle` 타입만 받도록 되돌립니다.
- 실시간 캔들 스트림 이펙트에서 에러 발생 시, 다른 스트림과 마찬가지로 일단 에러를 무시하고 성공적으로 캔들 데이터를 받았을 때만 액션을 보내도록 수정합니다.
- 리듀서가 `case let .candleUpdated(candle):`을 처리하도록 복원합니다.

## 파일 내용 변경

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift`

```swift
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
import AsyncAlgorithms

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
        case candleUpdated(Candle) // Reverted to simple Equatable type
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
        let buyPercent: Int, sellPercent: Int, bullets: [String]
    }

    // MARK: - Reducer
    @Dependency(\.currencyDetailStreaming) var streaming
    @Dependency(\.binanceAPIClient) var binanceAPIClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false

                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews),
                    .send(.computeInsight),
                    // Price Ticker Stream
                    .run { [symbol = state.symbol] send in
                        defer { streaming.disconnect() }
                        do {
                            for try await tick in streaming.connect(symbol).throttle(for: .milliseconds(500)) {
                                await send(.tickReceived(tick))
                            }
                        } catch {
                            // Swallow streaming errors for now
                        }
                    }
                    .cancellable(id: CancelID.detailSocket, cancelInFlight: true),
                    // Kline (Candle) Stream
                    .run { [symbol = state.symbol] send in
                        defer { binanceAPIClient.disconnectKlineStream() }
                        do {
                            for try await candle in binanceAPIClient.streamKline(symbol, "1d").throttle(for: .seconds(1)) {
                                await send(.candleUpdated(candle))
                            }
                        } catch {
                            // Swallow streaming errors for now
                        }
                    }
                    .cancellable(id: CancelID.klineSocket, cancelInFlight: true)
                )

            case .onDisappear:
                return .none

            case let .tickReceived(tick):
                if let mid = tick.midPrice {
                    state.midPrice = mid
                    if let prevClose = state.previousClosePrice {
                        state.priceChange24h = mid - prevClose
                    }
                }
                if let change = tick.changePercent24h {
                    state.changePercent24h = change
                }
                return .none

            case .fetchChart:
                state.chartLoading = true
                state.chartError = nil
                return .run { [symbol = state.symbol] send in
                    await send(.chartResponse(Result {
                        try await binanceAPIClient.fetchKlines(symbol, "1d", 7)
                    }))
                } catch: { error, send in
                    await send(.chartResponse(.failure(.network(error.localizedDescription))))
                }

            case let .chartResponse(.success(candles)):
                state.chartLoading = false
                state.candles = candles
                return .send(.computeInsight)

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
                    state.candles[state.candles.count - 1] = candle
                } else if let lastCandle = state.candles.last, candle.openTimeMs > lastCandle.openTimeMs {
                    state.candles.append(candle)
                    if state.candles.count > 7 {
                        state.candles.removeFirst()
                    }
                }
                return .none

            // ... (rest of the cases)
            case .fetchNews:
                state.newsLoading = true
                state.newsError = nil
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

            case .computeInsight:
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
        var buy = 50, sell = 50
        if let first = candles.first, let last = candles.last {
            if last.close > first.open { buy = 70; sell = 30 }
            else if last.close < first.open { buy = 30; sell = 70 }
        }
        var bullets: [String] = ["현재 \(symbol)의 추세를 기반으로 한 간단 분석입니다."]
        if !candles.isEmpty { bullets.append("최근 7일(1D) 캔들 흐름을 반영했습니다.") }
        if !news.isEmpty { bullets.append("관련 뉴스 신호를 함께 고려했습니다.") }
        else { bullets.append("현재는 뉴스 데이터가 없어 차트 중심으로 판단합니다.") }
        return Insight(buyPercent: buy, sellPercent: sell, bullets: bullets)
    }
}
```