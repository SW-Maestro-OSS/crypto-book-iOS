import SwiftUI
import ComposableArchitecture
import Domain

struct MainView: View {
    @Perception.Bindable var store: StoreOf<MainFeature>

    var body: some View {
        WithPerceptionTracking {
            TabView {
                VStack(spacing: 0) {
                    // Header with sort buttons
                    HStack {
                        Button {
                            store.send(.sortBySymbolTapped)
                        } label: {
                            HStack(spacing: 4) {
                                Text("Symbol")
                                Image(systemName: sortIcon(for: .symbol, sortKey: store.sortKey, sortOrder: store.sortOrder))
                            }
                        }

                        Spacer()

                        Button {
                            store.send(.sortByPriceTapped)
                        } label: {
                            HStack(spacing: 4) {
                                Text("Price ($)")
                                Image(systemName: sortIcon(for: .price, sortKey: store.sortKey, sortOrder: store.sortOrder))
                            }
                        }

                        Spacer()

                        Button {
                            store.send(.sortByChangeTapped)
                        } label: {
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
                            HStack(spacing: 12) {
                                // Placeholder image
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(ticker.symbol)
                                        .font(.subheadline.bold())
                                    Text("Vol: \(Int(ticker.quoteVolume))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(String(format: "%.4f", ticker.lastPrice))
                                        .font(.subheadline)

                                    let change = ticker.priceChangePercent
                                    Text(String(format: "%.2f%%", change))
                                        .font(.caption.bold())
                                        .foregroundStyle(changeColor(change))
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        if store.sortedTickers.count > store.visibleCount && store.visibleCount < 30 {
                            Button {
                                store.send(.showMoreTapped)
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("더 보기")
                                    Spacer()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                .tabItem {
                    Label("Market", systemImage: "list.bullet")
                }

                SettingsView()    // 나중에 Feature로 바꿀 예정
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
