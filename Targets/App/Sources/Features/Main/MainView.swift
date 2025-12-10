import SwiftUI
import ComposableArchitecture

struct MainView: View {
    @Perception.Bindable var store: StoreOf<MainFeature>

    var body: some View {
        WithPerceptionTracking {
            TabView {
                MarketView()      // 나중에 Feature로 바꿀 예정
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
