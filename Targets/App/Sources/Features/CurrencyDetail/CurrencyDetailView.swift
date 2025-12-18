import SwiftUI
import ComposableArchitecture

struct CurrencyDetailView: View {
    @Perception.Bindable var store: StoreOf<CurrencyDetailFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack(alignment: .leading, spacing: 12) {
                Text(store.symbol)
                    .font(.title2)

                if let mid = store.midPrice {
                    Text("Mid Price: \(mid)")
                } else {
                    Text("Mid Price: -")
                }

                Text("24h Change %: \(store.changePercent24h)")

                if let last = store.lastUpdated {
                    Text("Last Updated: \(last.formatted())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }


                Spacer()
            }
            .padding()
            .navigationTitle("Detail")
            .onAppear { store.send(.onAppear) }
            .onDisappear { store.send(.onDisappear) }
        }
    }
}

#Preview {
    CurrencyDetailView(
        store: Store(
            initialState: CurrencyDetailFeature.State(symbol: "BTCUSDT")
        ) {
            CurrencyDetailFeature()
        }
    )
}
