# 캔들 차트 날짜 표시 형식 수정

`CandleChartView`의 각 캔들 막대 아래에 날짜를 표시하고, 그 형식을 'Dec 26'과 같은 월(Month) 약어 없이 숫자 '26'만 표시되도록 수정합니다.

## 파일 내용 변경

### `Targets/App/Sources/Features/CurrencyDetail/CandleChartView.swift`

- 각 `CandleBarView` 아래에 날짜를 표시하는 `Text` 뷰를 추가합니다.
- 캔들의 타임스탬프(`openTimeMs`)를 'd' 형식으로 포맷하여 일(day)만 표시하는 `formatDay` 함수를 구현합니다.

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
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(candles) { candle in
                VStack(spacing: 4) {
                    CandleBarView(candle: candle, priceRange: priceRange)
                    
                    Text(formatDay(from: candle.openTimeMs))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(height: 150)
        .drawingGroup() // 복잡한 뷰 계층을 단일 레이어로 렌더링하여 성능을 향상시킵니다.
    }
    
    private func formatDay(from timestamp: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "d" // "d" for day of the month (e.g., "26")
        return formatter.string(from: date)
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
