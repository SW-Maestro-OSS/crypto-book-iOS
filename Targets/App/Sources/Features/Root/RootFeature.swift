import ComposableArchitecture
import Entity
import Foundation
import Infra

@Reducer
struct RootFeature {
  @ObservableState
  struct State: Equatable {
    var route: Route = .splash
    var main: MainFeature.State
    var exchangeRate: Double?

    init() {
      @Dependency(\.appClient) var appClient
      let currentLanguageCode = appClient.currentLanguage()
      let currentLanguage: SettingsFeature.Language =
        (currentLanguageCode == "ko") ? .korean : .english
      self.main = MainFeature.State(
        settings: .init(selectedLanguage: currentLanguage)
      )
    }
  }

  enum Route {
    case splash
    case main
  }

  enum Action {
    case onAppear
    case splashTimerFinished
    case marketTickerResponse(Result<[MarketTicker], Error>)
    case exchangeRateResponse(Result<Double, Error>)
    case main(MainFeature.Action)
  }

  @Dependency(\.appClient) var appClient
  @Dependency(\.continuousClock) var clock
  @Dependency(\.exchangeRateClient) var exchangeRateClient
  @Dependency(\.imageCache) var imageCache
  @Dependency(\.marketTicker) var marketTicker

  private enum CancelID { case marketTicker }

  var body: some Reducer<State, Action> {
    Scope(state: \.main, action: \.main) {
      MainFeature()
    }

    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          .run { send in
            try await clock.sleep(for: .seconds(2))
            await send(.splashTimerFinished)
          },
          .run { send in
            do {
              for try await tickers in marketTicker.stream() {
                await send(.marketTickerResponse(.success(tickers)))
              }
            } catch {
              await send(.marketTickerResponse(.failure(error)))
            }
          }
          .cancellable(id: CancelID.marketTicker),
          .run { send in
            print("[RootFeature] Fetching exchange rate...")
            await send(
              .exchangeRateResponse(
                Result {
                  try await exchangeRateClient.fetchUSDtoKRW()
                }))
          }
        )

      case .splashTimerFinished:
        state.route = .main
        return .none

      case let .marketTickerResponse(.success(tickers)):
        let urls = tickers.compactMap { $0.iconURL }.compactMap(URL.init)
        return .merge(
          .send(.main(.tickersUpdated(tickers))),
          .run { _ in
            await imageCache.prefetch(urls)
          }
        )

      case let .marketTickerResponse(.failure(error)):
        print("⚠️ marketTicker stream error:", error)
        return .none

      case let .exchangeRateResponse(.success(rate)):
        state.exchangeRate = rate
        print("[RootFeature] Exchange rate fetched: \(rate) KRW/USD")
        return .send(.main(.setExchangeRate(rate)))

      case let .exchangeRateResponse(.failure(error)):
        print("⚠️ exchangeRate fetch error:", error)
        return .none

      case .main:
        return .none
      }
    }
  }
}

