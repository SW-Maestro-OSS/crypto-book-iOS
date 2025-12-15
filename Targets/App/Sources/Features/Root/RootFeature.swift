//
//  RootFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Entity

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
        case main(MainFeature.Action)
    }
    
    @Dependency(\.continuousClock) var clock
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
                    .cancellable(id: CancelID.marketTicker)
                )
                
            case .splashTimerFinished:
                state.route = .main
                return .none
                
            case let .marketTickerResponse(.success(tickers)):
                return .send(.main(.tickersUpdated(tickers)))
                
            case let .marketTickerResponse(.failure(error)):
                // TODO: 에러 처리
                print("⚠️ marketTicker stream error:", error)
                return .none
                
            case .main:
                return .none
            }
        }
    }
}

