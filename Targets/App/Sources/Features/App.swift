import SwiftUI
import ComposableArchitecture

@main
struct CryptoBookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: RootFeature.State()) {
                    RootFeature()
                }
            )
        }
    }
}
