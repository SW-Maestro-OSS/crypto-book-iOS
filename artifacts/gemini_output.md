# TCA Presentation Race Condition 해결

`DetailView`가 닫힐 때 발생하는 런타임 크래시는, SwiftUI 뷰의 `.onDisappear` 생명주기와 TCA의 상태 업데이트 간의 경합(Race Condition) 때문에 발생합니다.

이 문제를 해결하기 위해, 예측 불가능한 `.onDisappear` 시점에 의존하여 수동으로 리소스를 정리하는 대신, TCA의 구조화된 동시성(Structured Concurrency)을 활용하여 이펙트의 생명주기에 정리 로직을 통합합니다.

## 파일 내용 변경

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift`

1.  **`.onDisappear` 로직 제거**: `.onDisappear` 케이스에서 수동으로 이펙트를 취소하고 스트림 연결을 해제하는 코드를 삭제합니다. 이로써 경합 상태의 직접적인 원인을 제거합니다.
2.  **`.onAppear` 이펙트 수정**: `.run` 이펙트 내부에 `defer` 구문을 추가합니다. 이펙트가 시작될 때 `streaming.connect()`를 호출하고, 이펙트가 취소될 때(화면이 닫혀서 TCA가 자동으로 이펙트를 취소시킬 때) `defer` 블록이 실행되어 `streaming.disconnect()`를 호출하도록 보장합니다.

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

@Reducer
struct CurrencyDetailFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let symbol: String

        // Header (live-ish)
        var midPrice: Double?
        var changePercent24h: Double?
        var lastUpdated: Date?

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

        init(symbol: String) {
            self.symbol = symbol
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case onDisappear

        // Header live updates (from WS)
        case midPriceUpdated(Double)
        case changePercent24hUpdated(Double)
        case tickReceived(CurrencyDetailTick)

        // Chart
        case fetchChart
        case chartResponse(Result<[Candle], ChartError>)

        // News
        case fetchNews
        case newsResponse(Result<[NewsArticle], NewsError>)

        // Insight
        case computeInsight
        case insightComputed(Insight)

        // UI
        case refreshPulled
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
                        defer {
                            // This block is guaranteed to run when the effect is cancelled.
                            streaming.disconnect()
                        }
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
                // The cleanup logic has been moved to the .onAppear effect's lifecycle.
                // This action is no longer needed to prevent race conditions.
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
                }
                if let change = tick.changePercent24h {
                    state.changePercent24h = change
                }
                state.lastUpdated = Date()
                return .none

            // MARK: Chart
            case .fetchChart:
                state.chartLoading = true
                state.chartError = nil

                // TODO: Replace with real REST call (e.g. /api/v3/uiKlines interval=1d limit=7)
                // For now, return empty to keep structure.
                return .send(.chartResponse(.success([])))

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

            // MARK: UI
            case .refreshPulled:
                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews)
                )

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
```
