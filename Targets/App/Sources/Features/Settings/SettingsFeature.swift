import ComposableArchitecture
import Infra

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        var selectedCurrency: CurrencyUnit = .usd
        var selectedLanguage: Language = .english
        var exchangeRate: Double?
        var isLoadingRate: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchExchangeRate
        case exchangeRateResponse(Result<Double, Error>)
    }

    enum Language: String, CaseIterable, Equatable, Identifiable {
        case english = "English"
        case korean = "한국어"

        var id: Self { self }
    }

    @Dependency(\.exchangeRateClient) var exchangeRateClient

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
            }
        }
    }
}
