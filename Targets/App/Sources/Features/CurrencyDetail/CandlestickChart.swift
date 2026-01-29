import SwiftUI
import Charts
import Entity

struct CandlestickChart: View {
    let candles: [Candle]

    var body: some View {
        Chart(Array(candles.enumerated()), id: \.element.openTimeMs) { index, candle in
            // Wick (심지): high ~ low
            RuleMark(
                x: .value("Index", dayLabel(candle)),
                yStart: .value("Low", candle.low),
                yEnd: .value("High", candle.high)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(candleColor(candle))

            // Body (몸통): open ~ close
            RectangleMark(
                x: .value("Index", dayLabel(candle)),
                yStart: .value("Open", candle.open),
                yEnd: .value("Close", candle.close),
                width: .fixed(16)
            )
            .foregroundStyle(candleColor(candle))
        }
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing) { value in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartYScale(domain: yAxisDomain)
    }

    // MARK: - Helpers

    private func dayLabel(_ candle: Candle) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(candle.openTimeMs) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func candleColor(_ candle: Candle) -> Color {
        candle.close >= candle.open ? .green : .red
    }

    private var yAxisDomain: ClosedRange<Double> {
        guard !candles.isEmpty else { return 0...1 }

        let minLow = candles.map(\.low).min() ?? 0
        let maxHigh = candles.map(\.high).max() ?? 1

        let padding = (maxHigh - minLow) * 0.05
        return (minLow - padding)...(maxHigh + padding)
    }
}
