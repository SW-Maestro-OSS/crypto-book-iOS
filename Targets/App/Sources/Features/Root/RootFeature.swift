import ComposableArchitecture
import Entity
import Foundation
import Kingfisher

@Reducer
struct RootFeature {
    @ObservableState
    struct State: Equatable {
        var route: Route = .splash
        var main = MainFeature.State()
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

    @Dependency(\.continuousClock) var clock
    @Dependency(\.exchangeRateClient) var exchangeRateClient
    @Dependency(\.marketTickerStream) var marketTickerStream
    
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
                            for try await tickers in marketTickerStream.stream() {
                                await send(.marketTickerResponse(.success(tickers)))
                            }
                        } catch {
                            await send(.marketTickerResponse(.failure(error)))
                        }
                    }
                        .cancellable(id: CancelID.marketTicker),
                    .run { send in
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
                        ImagePrefetcher(urls: urls).start()
                    }
                )
                
            case let .marketTickerResponse(.failure(error)):
                print("⚠️ marketTicker stream error:", error)
                return .none
                
            case let .exchangeRateResponse(.success(rate)):
                state.main.settings.$exchangeRate.withLock { $0 = rate }
                return .none
                
            case let .exchangeRateResponse(.failure(error)):
                print("⚠️ exchangeRate fetch error:", error)
                return .none
                
            case .main:
                return .none
            }
        }
    }
}

