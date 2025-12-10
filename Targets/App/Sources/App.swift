import SwiftUI
import Domain
import Data
import Infra

@main
struct CryptoBookApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .onAppear {
                            Task {
                                try? await Task.sleep(for: .seconds(2))
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    MainView()
                }
            }
        }
    }
}
