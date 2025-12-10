import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            MarketView()
                .tabItem {
                    Label("Market", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}


#Preview {
    MainView()
}
