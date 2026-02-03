import ComposableArchitecture
import Entity

@Reducer
struct SettingsFeature {
    @ObservableState
    struct State: Equatable {
        @Shared(.appStorage("selectedCurrency")) var selectedCurrency: CurrencyUnit = .usd
        @Shared(.appStorage("selectedLanguage")) var selectedLanguage: Language = .english
        @Shared(.appStorage("exchangeRate")) var exchangeRate: Double = 0
        var isLoadingRate: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case fetchExchangeRate
        case exchangeRateResponse(Result<Double, Error>)
    }

    enum Language: String, CaseIterable, Equatable, Identifiable, Sendable {
        case english = "en"
        case korean = "ko"

        var id: Self { self }

        var displayName: String {
            switch self {
            case .english: "English"
            case .korean: "한국어"
            }
        }
    }

    @Dependency(\.exchangeRateClient) var exchangeRateClient

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.selectedCurrency):
                if state.selectedCurrency == .krw {
                    return .send(.fetchExchangeRate)
                }
                return .none

            case .binding:
                return .none

            case .fetchExchangeRate:
                state.isLoadingRate = true
                return .run { send in
                    do {
                        let rate = try await exchangeRateClient.fetchUSDtoKRW()
                        await send(.exchangeRateResponse(.success(rate)))
                    } catch {
                        await send(.exchangeRateResponse(.failure(error)))
                    }
                }

            case let .exchangeRateResponse(.success(rate)):
                state.isLoadingRate = false
                state.$exchangeRate.withLock { $0 = rate }
                return .none

            case .exchangeRateResponse(.failure(_)):
                state.isLoadingRate = false
                return .none
            }
        }
    }
}
