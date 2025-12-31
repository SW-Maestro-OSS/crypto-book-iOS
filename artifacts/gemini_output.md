# `CurrencyDetailView` 로컬라이제이션 키 적용 수정

`CurrencyDetailView.swift`에 하드코딩되어 있던 한국어 문자열들을 `Localizable.xcstrings`의 키로 올바르게 교체하고, 누락되었던 키들을 추가합니다.

## 1. `Localizable.xcstrings` 수정

AI Insight 섹션에서 사용되는 "매수", "매도", "분석 중..." 텍스트에 대한 키와 번역을 추가합니다.

```json
{
  "sourceLanguage" : "en",
  "strings" : {
    "detail.ai.buy" : {
      "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Buy %@" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "매수 %@" } } }
    },
    "detail.ai.loading" : {
      "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Analyzing..." } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "분석 중..." } } }
    },
    "detail.ai.sell" : {
      "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Sell %@" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "매도 %@" } } }
    },
    "detail.ai.title" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "AI Insight" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "AI 분석" } } } },
    "detail.chart.noData" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Cannot load chart data." } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "차트 데이터를 불러올 수 없습니다." } } } },
    "detail.chart.title" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "7D Chart (1D Interval)" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "7일 차트 (1일 간격)" } } } },
    "detail.header.yesterdayClose" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Yesterday's Close %@" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "어제의 종가 %@" } } } },
    "main.header.change" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "24h Change %" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "24시간 등락률" } } } },
    "main.header.price" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Price" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "가격" } } } },
    "main.header.symbol" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Symbol" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "심볼" } } } },
    "main.list.volume" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Vol: %@" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "거래량: %@" } } } },
    "settings.navigation.title" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Settings" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "설정" } } } },
    "settings.picker.currency" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Currency Unit" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "통화 단위" } } } },
    "settings.picker.language" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "App Language" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "앱 언어" } } } },
    "settings.section.language" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Language" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "언어" } } } },
    "settings.section.price" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Price Display" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "가격 표시" } } } },
    "tab.market" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Market" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "마켓" } } } },
    "tab.settings" : { "localizations" : { "en" : { "stringUnit" : { "state" : "translated", "value" : "Settings" } }, "ko" : { "stringUnit" : { "state" : "translated", "value" : "설정" } } } }
  },
  "version" : "1.1"
}
```

## 2. `CurrencyDetailView.swift` 수정

하드코딩된 모든 문자열을 로컬라이제이션 키로 교체합니다. 변수가 포함된 텍스트는 `String(format: NSLocalizedString(...))`을 사용합니다.

```swift
import SwiftUI
import Charts
import ComposableArchitecture
import Entity
import Infra

struct CurrencyDetailView: View {
    @Perception.Bindable var store: StoreOf<CurrencyDetailFeature>
    @Environment(\.openURL) var openURL

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection(
                        midPrice: store.midPrice,
                        previousClosePrice: store.previousClosePrice,
                        priceChange24h: store.priceChange24h,
                        changePercent24h: store.changePercent24h,
                        currency: store.selectedCurrency,
                        exchangeRate: store.exchangeRate
                    )
                    Divider()
                    chartSection
                    Divider()
                    aiInsightSection
                    Divider()
                }
                .padding()
            }
            .navigationTitle(store.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
        }
    }

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
                if currency == .usd {
                    Text("USDT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }
            }
            if let prevClose = previousClosePrice,
               let priceChange = priceChange24h,
               let percentChange = changePercent24h {
                let sign = priceChange >= 0 ? "+" : ""
                let color: Color = priceChange >= 0 ? .green : .red
                let formattedPrevClose = PriceFormatter.format(price: prevClose, currency: currency, exchangeRate: exchangeRate)
                let formattedPriceChange = PriceFormatter.format(price: abs(priceChange), currency: currency, exchangeRate: exchangeRate)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(format: NSLocalizedString("detail.header.yesterdayClose", comment: ""), formattedPrevClose))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(sign)\(formattedPriceChange) (\(sign)\(String(format: "%.2f", percentChange))%)")
                        .font(.subheadline.bold())
                        .foregroundStyle(color)
                }
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("detail.chart.title")
                .font(.headline)
            if store.chartLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if store.candles.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(Text("detail.chart.noData").font(.caption))
            } else {
                CandlestickChart(candles: store.candles)
                    .frame(height: 200)
            }
        }
    }

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("detail.ai.title")
                .font(.headline)
            if let insight = store.insight {
                VStack(spacing: 12) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: CGFloat(insight.sellPercent) * 2.5, height: 20)
                            .overlay(Text(String(format: NSLocalizedString("detail.ai.sell", comment: ""), "\(insight.sellPercent)"))
                                .font(.caption2).bold().white(), alignment: .leading)
                        Rectangle()
                            .fill(.green)
                            .frame(width: CGFloat(insight.buyPercent) * 2.5, height: 20)
                            .overlay(Text(String(format: NSLocalizedString("detail.ai.buy", comment: ""), "\(insight.buyPercent)"))
                                .font(.caption2).bold().white(), alignment: .trailing)
                    }
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
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
                ProgressView("detail.ai.loading")
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

extension View {
    func white() -> some View { self.foregroundStyle(.white) }
}
```
