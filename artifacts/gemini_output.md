# 캔들 차트 시각화 구현

`CurrencyDetailView`에 표시되는 차트 데이터를 실제 캔들 차트 형태로 시각화합니다. 이를 위해 캔들 차트를 그리는 `CandleChartView`를 새로 생성하고, 기존의 임시 UI(Placeholder)를 교체합니다.

## 신규 파일 생성

### `Targets/App/Sources/Features/CurrencyDetail/CandleChartView.swift`

불러온 `[Candle]` 데이터를 받아 간단한 막대 차트 형태로 그려주는 SwiftUI 뷰를 새로 생성합니다.

- `Canvas`를 사용하여 각 캔들의 고가/저가(꼬리)와 시가/종가(몸통)를 그립니다.
- 상승(종가 >= 시가)은 녹색, 하락은 빨간색으로 표시합니다.
- 전달된 캔들들의 가격 범위를 기준으로 각 캔들의 높이와 위치를 정규화하여 표시합니다.

```swift
import SwiftUI
import Entity

struct CandleChartView: View {
    let candles: [Candle]

    private var priceRange: ClosedRange<Double> {
        let minPrice = candles.map(\.low).min() ?? 0
        let maxPrice = candles.map(\.high).max() ?? 1
        // 차트의 상하단에 약간의 여백을 줍니다.
        let padding = (maxPrice - minPrice) * 0.1
        return (minPrice - padding)...(maxPrice + padding)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(Array(candles.enumerated()), id: \.offset) { _, candle in
                CandleBarView(candle: candle, priceRange: priceRange)
            }
        }
        .frame(height: 150)
        .drawingGroup() // 복잡한 뷰 계층을 단일 레이어로 렌더링하여 성능을 향상시킵니다.
    }
}

struct CandleBarView: View {
    let candle: Candle
    let priceRange: ClosedRange<Double>

    var body: some View {
        let isUp = candle.close >= candle.open
        let color = isUp ? Color.green : Color.red
        
        let range = priceRange.upperBound - priceRange.lowerBound
        guard range > 0 else {
            // 가격 변동이 없는 경우 아무것도 그리지 않습니다.
            return AnyView(EmptyView())
        }

        // 캔들의 각 가격을 0(상단) ~ 1(하단) 사이의 상대적인 Y좌표로 변환합니다.
        let yHigh = 1 - ((candle.high - priceRange.lowerBound) / range)
        let yLow = 1 - ((candle.low - priceRange.lowerBound) / range)
        
        let yOpen = 1 - ((candle.open - priceRange.lowerBound) / range)
        let yClose = 1 - ((candle.close - priceRange.lowerBound) / range)

        return AnyView(
            Canvas { context, size in
                // 꼬리 (Wick)
                let wickPath = Path { p in
                    p.move(to: CGPoint(x: size.width / 2, y: size.height * yHigh))
                    p.addLine(to: CGPoint(x: size.width / 2, y: size.height * yLow))
                }
                context.stroke(wickPath, with: .color(color), lineWidth: 1)

                // 몸통 (Body)
                let bodyHeight = size.height * abs(yOpen - yClose)
                let bodyRect = CGRect(
                    x: size.width / 2 - 3,
                    y: size.height * min(yOpen, yClose),
                    width: 6,
                    height: bodyHeight > 1 ? bodyHeight : 1 // 최소 높이를 1로 보장
                )
                context.fill(Path(bodyRect), with: .color(color))
            }
        )
    }
}
```

## 파일 내용 변경

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailView.swift`

기존 `chartSection`의 임시 UI를 새로 만든 `CandleChartView`로 교체합니다.

```swift
import SwiftUI
import ComposableArchitecture
import Entity
import Infra // CachedAsyncImage 사용을 위함

struct CurrencyDetailView: View {
    @Perception.Bindable var store: StoreOf<CurrencyDetailFeature>
    @Environment(\.openURL) var openURL // 뉴스 URL을 열기 위함

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Header Section: 실시간 가격 및 등락률
                    headerSection(
                        midPrice: store.midPrice,
                        changePercent24h: store.changePercent24h,
                        lastUpdated: store.lastUpdated
                    )
                    
                    Divider()

                    // 2. Chart Section: 7일 캔들 차트
                    chartSection
                    
                    Divider()

                    // 3. AI Insight Section: 매수/매도 심리 및 분석 요약
                    aiInsightSection
                    
                    Divider()

                    // 4. News Section: 관련 종목 뉴스 및 아티클
                   // newsSection
                }
                .padding()
            }
            .navigationTitle(store.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // 당겨서 새로고침
                await store.send(.refreshPulled).finish()
            }
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Subviews

    private func headerSection(
        midPrice: Double?,
        changePercent24h: Double?,
        lastUpdated: Date?
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

            if let change = changePercent24h {
                HStack {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.2f%%", change))
                    Text("지난 24시간")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.bold())
                .foregroundStyle(change >= 0 ? .green : .red) // 양전 초록, 음전 빨강
            }
            
            if let lastUpdated {
                Text("최근 업데이트: \(lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7D Chart (1D Interval)")
                .font(.headline)
            
            if store.chartLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else if store.candles.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(Text("차트 데이터를 불러올 수 없습니다.").font(.caption))
            } else {
                CandleChartView(candles: store.candles)
            }
        }
    }

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insight")
                .font(.headline)
            
            if let insight = store.insight {
                VStack(spacing: 12) {
                    // 매수/매도 게이지 바
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: CGFloat(insight.sellPercent) * 2.5, height: 20)
                            .overlay(Text("매도 \(insight.sellPercent)").font(.caption2).bold().white(), alignment: .leading)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(width: CGFloat(insight.buyPercent) * 2.5, height: 20)
                            .overlay(Text("매수 \(insight.buyPercent)").font(.caption2).bold().white(), alignment: .trailing)
                    }
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
                    
                    // 인사이트 요약 불렛 포인트
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(insight.bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(bullet)
                                    .font(.subheadline)
                                    .lineLimit(nil)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else if store.insightLoading {
                ProgressView("분석 중...")
                    .frame(maxWidth: .infinity)
            }
        }
    }

}

// 텍스트 색상 편의를 위한 확장
extension View {
    func white() -> some View { self.foregroundStyle(.white) }
}
```