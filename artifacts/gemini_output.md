# 언어 변경 시 재시작 기능 구현

`SettingsFeature`에 언어 변경 시 사용자에게 알림을 표시하고 앱을 재시작(종료)하는 기능을 추가합니다.

## 1. `AppClient` 의존성 추가

앱 종료 및 언어 설정 저장을 위한 `AppClient`를 새로 추가합니다. 이 클라이언트는 TCA의 의존성 관리 시스템을 사용하여 로직을 분리하고 테스트 용이성을 높입니다.

**File: `Targets/App/Sources/Dependencies/AppClient.swift` (New File)**
```swift
import ComposableArchitecture
import Foundation

@DependencyClient
struct AppClient {
    var setLanguage: @Sendable (String) -> Void
    var terminate: @Sendable () -> Void
}

extension AppClient: DependencyKey {
    static let liveValue = Self(
        setLanguage: { lang in
            // "AppleLanguages" 키를 사용하여 UserDefaults에 사용자가 선택한 언어를 저장합니다.
            // 앱이 다음 번에 시작될 때 이 설정을 사용하게 됩니다.
            UserDefaults.standard.set([lang], forKey: "AppleLanguages")
        },
        terminate: {
            // 앱을 종료합니다.
            exit(0)
        }
    )
    
    static let testValue = Self(
        setLanguage: { _ in },
        terminate: { }
    )
}

extension DependencyValues {
    var appClient: AppClient {
        get { self[AppClient.self] }
        set { self[AppClient.self] = newValue }
    }
}
```

## 2. `SettingsFeature` 수정

언어 변경을 감지하고, Alert을 표시하며, 재시작 액션을 처리하는 로직을 `SettingsFeature`에 추가합니다.

**File: `Targets/App/Sources/Features/Settings/SettingsFeature.swift` (Updated)**
```swift
import ComposableArchitecture
import Infra
import SwiftUI // For TextState

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var selectedCurrency: CurrencyUnit = .usd
        var selectedLanguage: Language = .english
        var exchangeRate: Double?
        var isLoadingRate: Bool = false
        
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchExchangeRate
        case exchangeRateResponse(Result<Double, Error>)
        case alert(PresentationAction<Alert>)
        
        enum Alert: Equatable {
            case restartButtonTapped
        }
    }

    enum Language: String, CaseIterable, Equatable, Identifiable {
        case english = "English"
        case korean = "한국어"

        var id: Self { self }
        
        var localeIdentifier: String {
            switch self {
            case .english: "en"
            case .korean: "ko"
            }
        }
    }

    @Dependency(\.exchangeRateClient) var exchangeRateClient
    @Dependency(\.appClient) var appClient

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.selectedCurrency):
                print("[SettingsFeature] Currency changed to: \(state.selectedCurrency)")
                if state.selectedCurrency == .krw {
                    return .send(.fetchExchangeRate)
                }
                return .none
                
            case .binding(\.selectedLanguage):
                let selectedLanguage = state.selectedLanguage
                state.alert = .init(
                    title: { TextState("alert.restart.title") },
                    message: { TextState("alert.restart.message") },
                    buttons: [
                        .destructive(TextState("alert.restart.button.confirm"), action: .send(.restartButtonTapped)),
                        .cancel(TextState("alert.restart.button.cancel"))
                    ]
                )
                return .run { _ in
                    await appClient.setLanguage(selectedLanguage.localeIdentifier)
                }

            case .binding:
                return .none

            case .fetchExchangeRate:
                state.isLoadingRate = true
                print("[SettingsFeature] Fetching USD -> KRW exchange rate...")
                return .run { send in
                    do {
                        let rate = try await exchangeRateClient.fetchUSDtoKRW()
                        print("[SettingsFeature] Exchange rate fetched: \(rate)")
                        await send(.exchangeRateResponse(.success(rate)))
                    } catch {
                        print("[SettingsFeature] Exchange rate error: \(error)")
                        await send(.exchangeRateResponse(.failure(error)))
                    }
                }

            case let .exchangeRateResponse(.success(rate)):
                state.isLoadingRate = false
                state.exchangeRate = rate
                print("[SettingsFeature] Exchange rate stored: \(rate) KRW/USD")
                return .none

            case let .exchangeRateResponse(.failure(error)):
                state.isLoadingRate = false
                print("[SettingsFeature] Failed to fetch rate: \(error.localizedDescription)")
                return .none
                
            case .alert(.presented(.restartButtonTapped)):
                return .run { _ in
                    await appClient.terminate()
                }
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
```

## 3. `Localizable.xcstrings` 키 추가

재시작 Alert에 사용될 문자열 키와 번역을 추가합니다. 아래 내용을 `strings` 객체 안에 추가해주세요.

**File: `Targets/App/Resources/Localizable.xcstrings` (Additions)**
```json
    "alert.restart.title" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "new", "value" : "Restart Required" } },
        "ko" : { "stringUnit" : { "state" : "new", "value" : "재시작 필요" } }
      }
    },
    "alert.restart.message" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "new", "value" : "The app needs to be restarted to apply the language change." } },
        "ko" : { "stringUnit" : { "state" : "new", "value" : "언어 설정을 적용하려면 앱을 재시작해야 합니다." } }
      }
    },
    "alert.restart.button.confirm" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "new", "value" : "Restart" } },
        "ko" : { "stringUnit" : { "state" : "new", "value" : "재시작" } }
      }
    },
    "alert.restart.button.cancel" : {
      "localizations" : {
        "en" : { "stringUnit" : { "state" : "new", "value" : "Cancel" } },
        "ko" : { "stringUnit" : { "state" : "new", "value" : "취소" } }
      }
    }
```