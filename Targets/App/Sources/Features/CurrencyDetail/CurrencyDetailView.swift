import SwiftUI
import Charts
import ComposableArchitecture
import Entity

/// A view that displays detailed information about a specific cryptocurrency.
struct CurrencyDetailView: View {
    
    // MARK: - Properties
    
    @Perception.Bindable var store: StoreOf<CurrencyDetailFeature>

    // MARK: - Body
    
    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    Divider()
                    chartSection
                    Divider()
                    aiInsightSection
                    Divider()
                    newsSection
                }
                .padding()
            }
            .navigationTitle(store.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Subviews

    /// The header section displaying the current price and 24-hour change.
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                if let midPrice = store.midPrice {
                    Text(PriceFormatter.format(
                        price: midPrice,
                        currency: store.selectedCurrency,
                        exchangeRate: store.exchangeRate
                    ))
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                } else {
                    Text("---")
                        .font(.system(size: 32, weight: .bold))
                }

                if store.selectedCurrency == .usd {
                    Text("USDT")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 6)
                }
            }

            if let prevClose = store.previousClosePrice,
               let priceChange = store.priceChange24h,
               let percentChange = store.changePercent24h {

                let sign = priceChange >= 0 ? "+" : ""
                let color: Color = priceChange >= 0 ? .green : .red

                let formattedPrevClose = PriceFormatter.format(
                    price: prevClose,
                    currency: store.selectedCurrency,
                    exchangeRate: store.exchangeRate
                )
                let formattedPriceChange = PriceFormatter.format(
                    price: abs(priceChange),
                    currency: store.selectedCurrency,
                    exchangeRate: store.exchangeRate
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Yesterday's Close \(formattedPrevClose)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("\(sign)\(formattedPriceChange) (\(sign)\(String(format: "%.2f", percentChange))%)")
                        .font(.subheadline.bold())
                        .foregroundStyle(color)
                }
            }
        }
    }

    /// The chart section displaying a 7-day candlestick chart.
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7D Chart (1D Interval)")
                .font(.headline)

            if store.chartLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if store.candles.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(Text("Cannot load chart data.").font(.caption))
            } else {
                CandlestickChart(candles: store.candles)
                    .frame(height: 200)
            }
        }
    }

    /// The AI insight section displaying market sentiment and analysis.
    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insight")
                .font(.headline)
            
            if let insight = store.insight {
                VStack(spacing: 12) {
                    // Buy/Sell Gauge Bar
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: CGFloat(insight.sellPercent) * 2.5, height: 20)
                            .overlay(Text("Sell \(insight.sellPercent)").font(.caption2).bold().white(), alignment: .leading)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(width: CGFloat(insight.buyPercent) * 2.5, height: 20)
                            .overlay(Text("Buy \(insight.buyPercent)").font(.caption2).bold().white(), alignment: .trailing)
                    }
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
                    
                    // Insight Summary Bullets
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
                ProgressView("Analyzing...")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// The news section displaying related cryptocurrency news.
    private var newsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("News")
                .font(.headline)

            if store.newsLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else if store.news.isEmpty {
                emptyNewsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(store.news.prefix(10)) { article in
                        newsRow(article)
                    }
                }
            }
        }
    }

    private var emptyNewsView: some View {
        VStack(spacing: 8) {
            Image(systemName: "newspaper")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No news available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private func newsRow(_ article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.primary)

            Text(article.date, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - Extensions

private extension View {
    func white() -> some View { self.foregroundStyle(.white) }
}
