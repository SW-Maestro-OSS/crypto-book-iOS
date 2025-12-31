# 가격 표시 형식(KRW/USD) 적용

`Settings`에서 선택한 통화 단위와 `Root`에서 가져온 환율 정보를 사용하여, `MainView`와 `CurrencyDetailView`의 모든 가격 표시를 원화(KRW) 또는 달러(USD)로 올바르게 변환하여 보여주도록 수정합니다.

## 1. 데이터 흐름 수정

### `Targets/App/Sources/Features/Main/MainFeature.swift`

`CurrencyDetailFeature`로 진입할 때, 현재의 환율(`exchangeRate`)과 통화 설정(`selectedCurrency`)을 함께 전달하도록 수정합니다.

```swift
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
                        changePercent24h: ticker.priceChangePercent,
                        exchangeRate: state.exchangeRate, // Pass down
                        selectedCurrency: state.settings.selectedCurrency // Pass down
                    )
                )
                return .none
// ...
```

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift`

`MainFeature`로부터 환율과 통화 설정을 전달받아 `State`에 저장할 수 있도록 수정합니다.

```swift
// ...
    @ObservableState
    struct State: Equatable {
        let symbol: String
        let previousClosePrice: Double?

        // Shared State from Parent
        var exchangeRate: Double?
        var selectedCurrency: CurrencyUnit

        // Header (live-ish)
        var midPrice: Double?
        var priceChange24h: Double?
        var changePercent24h: Double?
        
        // ... (rest of State)

        init(
            symbol: String,
            previousClosePrice: Double?,
            priceChange24h: Double?,
            changePercent24h: Double?,
            exchangeRate: Double?,
            selectedCurrency: CurrencyUnit
        ) {
            self.symbol = symbol
            self.previousClosePrice = previousClosePrice
            self.priceChange24h = priceChange24h
            self.changePercent24h = changePercent24h
            self.exchangeRate = exchangeRate
            self.selectedCurrency = selectedCurrency
        }
    }
// ...
```

## 2. 뷰 수정

### `Targets/App/Sources/Features/Main/MainView.swift`

리스트의 가격을 표시하는 `Text` 뷰에서 `PriceFormatter`를 사용하도록 수정합니다.

```swift
// ...
import Infra
import Entity

// ...
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(
                                            PriceFormatter.format(
                                                price: ticker.lastPrice,
                                                currency: store.settings.selectedCurrency,
                                                exchangeRate: store.exchangeRate
                                            )
                                        )
                                        .font(.subheadline)

                                        let change = ticker.priceChangePercent
// ...
```

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailView.swift`

`headerSection`에서 모든 가격을 `PriceFormatter`를 사용하여 표시하도록 수정합니다.

```swift
// ...
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Header Section: 실시간 가격 및 등락률
                    headerSection(
                        midPrice: store.midPrice,
                        previousClosePrice: store.previousClosePrice,
                        priceChange24h: store.priceChange24h,
                        changePercent24h: store.changePercent24h,
                        currency: store.selectedCurrency,
                        exchangeRate: store.exchangeRate
                    )
// ...

    private func headerSection(
        midPrice: Double?,
        previousClosePrice: Double?,
        priceChange24h: Double?,
        changePercent24h: Double?,
        currency: CurrencyUnit,
        exchangeRate: Double?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                if let midPrice {
                    Text(PriceFormatter.format(price: midPrice, currency: currency, exchangeRate: exchangeRate))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                } else {
                    Text("---")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Text(currency == .krw ? "" : "USDT")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }

            if let prevClose = previousClosePrice,
               let priceChange = priceChange24h,
               let percentChange = changePercent24h {
                
                let sign = priceChange >= 0 ? "+" : ""
                let color: Color = priceChange >= 0 ? .green : .red
                
                let formattedPrevClose = PriceFormatter.format(price: prevClose, currency: currency, exchangeRate: exchangeRate)
                let formattedPriceChange = PriceFormatter.format(price: priceChange, currency: currency, exchangeRate: exchangeRate)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("어제의 종가 \(formattedPrevClose)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(sign)\(formattedPriceChange) (\(sign)\(String(format: "%.2f", percentChange))%)")
                        .font(.subheadline.bold())
                        .foregroundStyle(color)
                }
            }
        }
    }
// ...
```
