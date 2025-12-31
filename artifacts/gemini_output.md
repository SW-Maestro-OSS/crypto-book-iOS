# 디테일 뷰 UI 및 데이터 로직 수정

디테일 뷰의 헤더 UI를 요청사항에 맞게 변경하고, 이에 필요한 데이터 흐름을 수정합니다.

**주요 변경사항:**
1.  **'최근 업데이트' 시간 제거**: UI에서 해당 텍스트를 삭제합니다.
2.  **등락률 표시 형식 변경**: "어제의 종가 91,522.40 +228.20 (+0.25%)" 형식으로 변경합니다.
3.  **데이터 전달**: 위 UI를 위해, 메인 화면에서 디테일 화면으로 진입 시 '어제 종가' 데이터를 전달하도록 수정합니다.
4.  **상태 관리**: 디테일 뷰의 `State`가 '어제 종가'를 저장하고, 실시간 가격을 받을 때마다 '가격 변동폭'을 새로 계산하도록 로직을 변경합니다.

## 파일 내용 변경

### 1. `CurrencyDetailFeature.swift`

- `State`에 `previousClosePrice`와 `priceChange24h`를 추가하고, `lastUpdated`는 삭제합니다.
- `init`을 수정하여 `previousClosePrice`를 전달받도록 합니다.
- `.tickReceived` 케이스에서 `priceChange24h`를 실시간으로 재계산하는 로직을 추가합니다.

```swift
// Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift

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
        case candleUpdated(Result<Candle, Error>)
        case fetchNews
        case newsResponse(Result<[NewsArticle], NewsError>)
        case computeInsight
        case insightComputed(Insight)
        case newsItemTapped(NewsArticle)
    }

    // ... (Errors, CancelID, Models)

    // MARK: - Reducer
    @Dependency(\.currencyDetailStreaming) var streaming
    @Dependency(\.binanceAPIClient) var binanceAPIClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false
                // ... (effects)
            
            // ...

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

            // ... (other cases)
            }
        }
    }
    // ... (Helpers)
}
```

### 2. `MainFeature.swift`

- `.tickerTapped` 케이스에서, `MarketTicker` 데이터로부터 `previousClosePrice`를 계산하고, `priceChange24h`, `changePercent24h`와 함께 `CurrencyDetailFeature.State` 초기화 시 전달합니다.

```swift
// Targets/App/Sources/Features/Main/MainFeature.swift

// ...

            case let .tickerTapped(symbol):
                guard let ticker = state.tickers.first(where: { $0.symbol == symbol }) else {
                    return .none
                }
                let previousClosePrice = ticker.lastPrice - ticker.priceChange
                state.destination = .currencyDetail(
                    .init(
                        symbol: symbol,
                        previousClosePrice: previousClosePrice,
                        priceChange24h: ticker.priceChange,
                        changePercent24h: ticker.priceChangePercent
                    )
                )
                return .none
// ...
```

### 3. `CurrencyDetailView.swift`

- '최근 업데이트' 텍스트를 삭제합니다.
- `headerSection`의 등락률 표시 부분을 새로운 디자인과 데이터에 맞게 수정합니다.

```swift
// Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailView.swift

// ...

    private func headerSection(
        midPrice: Double?,
        previousClosePrice: Double?,
        priceChange24h: Double?,
        changePercent24h: Double?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                if let midPrice {
                    Text(String(format: "%.4f", midPrice))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                } else {
                    Text("---")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Text("USDT")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }

            if let prevClose = previousClosePrice,
               let priceChange = priceChange24h,
               let percentChange = changePercent24h {
                
                let sign = priceChange >= 0 ? "+" : ""
                let color: Color = priceChange >= 0 ? .green : .red
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("어제의 종가 \(String(format: "%.2f", prevClose))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(sign)\(String(format: "%.2f", priceChange)) (\(sign)\(String(format: "%.2f", percentChange))%)")
                        .font(.subheadline.bold())
                        .foregroundStyle(color)
                }
            }
        }
    }
// ...
```
