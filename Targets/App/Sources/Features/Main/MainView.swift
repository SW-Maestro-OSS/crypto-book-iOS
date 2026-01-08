import SwiftUI
import ComposableArchitecture
import Domain
import UIKit
import Infra

struct MainView: View {
    @Perception.Bindable var store: StoreOf<MainFeature>

    var body: some View {
        WithPerceptionTracking {
            TabView {
                // 1. NavigationStack 추가 (Push 네비게이션을 위해 필수)
                NavigationStack {
                    VStack(spacing: 0) {
                        // Header with sort buttons (기존 코드 유지)
                        HStack {
                            Button { store.send(.sortBySymbolTapped) } label: {
                                HStack(spacing: 4) {
                                    Text("Symbol")
                                    Image(systemName: sortIcon(for: .symbol, sortKey: store.sortKey, sortOrder: store.sortOrder))
                                }
                            }
                            Spacer()
                            Button { store.send(.sortByPriceTapped) } label: {
                                HStack(spacing: 4) {
                                    let currencySymbol = store.settings.selectedCurrency == .usd ? "$" : "₩"
                                    Text("Price (\(currencySymbol))")
                                    Image(systemName: sortIcon(for: .price, sortKey: store.sortKey, sortOrder: store.sortOrder))
                                }
                            }
                            Spacer()
                            Button { store.send(.sortByChangeTapped) } label: {
                                HStack(spacing: 4) {
                                    Text("24h Change %")
                                    Image(systemName: sortIcon(for: .changePercent, sortKey: store.sortKey, sortOrder: store.sortOrder))
                                }
                            }
                        }
                        .font(.caption.bold())
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                        Divider()

                        List {
                            ForEach(store.visibleTickers, id: \.symbol) { ticker in
                                WithPerceptionTracking {
                                    HStack(spacing: 12) {
                                        // Icon image
                                        CachedAsyncImage(url: URL(string: ticker.iconURL ?? ""))
                                            .frame(width: 24, height: 24)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(ticker.symbol)
                                                .font(.subheadline.bold())
                                            Text("Vol: \(Int(ticker.quoteVolume))")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

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
                                            Text(String(format: "%.2f%%", change))
                                                .font(.caption.bold())
                                                .foregroundStyle(changeColor(change))
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        store.send(.tickerTapped(ticker.symbol))
                                    }
                                    .onAppear {
                                        if ticker.symbol == store.visibleTickers.last?.symbol {
                                            store.send(.loadMore)
                                        }
                                    }
                                }
                            }

                            if store.visibleCount < store.sortedTickers.count {
                                ProgressView()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .listStyle(.plain)
                    }
                    .navigationDestination(
                        item: $store.scope(state: \.destination?.currencyDetail, action: \.destination.currencyDetail)
                    ) { detailStore in
                        CurrencyDetailView(store: detailStore)
                    }
                }
                .tabItem {
                    Label("Market", systemImage: "list.bullet")
                }

                SettingsView(store: store.scope(state: \.settings, action: \.settings))
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Subviews

private struct CachedAsyncImage: View {
    let url: URL?
    @Dependency(\.imageCache) var imageCache
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                // Placeholder
                Image(systemName: "circle.dashed")
                    .resizable()
            }
        }
        .task(id: url) {
            guard let url = url else { return }
            self.image = await imageCache.image(url)
        }
    }
}


// MARK: - Helper Functions

private func sortIcon(for key: MainSortKey, sortKey: MainSortKey?, sortOrder: MainSortOrder) -> String {
    guard let sortKey = sortKey, sortKey == key else {
        return "arrow.up.arrow.down"
    }
    return sortOrder == .ascending ? "arrow.up" : "arrow.down"
}

private func changeColor(_ changePercent: Double) -> Color {
    if changePercent > 0 {
        return .green
    } else if changePercent < 0 {
        return .red
    } else {
        return .secondary
    }
}
