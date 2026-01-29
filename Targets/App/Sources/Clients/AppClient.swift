import ComposableArchitecture
import Foundation

@DependencyClient
struct AppClient {
    var currentLanguage: @Sendable () -> String?
    var setLanguage: @Sendable (String) -> Void
    var currentCurrency: @Sendable () -> String?
    var setCurrency: @Sendable (String) -> Void
    var terminate: @Sendable () -> Void
}

extension AppClient: DependencyKey {
    static let liveValue = Self(
        currentLanguage: {
            UserDefaults.standard.stringArray(forKey: "AppleLanguages")?.first
        },
        setLanguage: { lang in
            UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        },
        currentCurrency: {
            UserDefaults.standard.string(forKey: "selectedCurrency")
        },
        setCurrency: { currencyRawValue in
            UserDefaults.standard.set(currencyRawValue, forKey: "selectedCurrency")
        },
        terminate: {
            exit(0)
        }
    )

    static let testValue = Self(
        currentLanguage: { "en" },
        setLanguage: { _ in },
        currentCurrency: { "usd" },
        setCurrency: { _ in },
        terminate: { }
    )
}

extension DependencyValues {
    var appClient: AppClient {
        get { self[AppClient.self] }
        set { self[AppClient.self] = newValue }
    }
}
