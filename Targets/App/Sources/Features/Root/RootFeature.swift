//
//  RootFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture

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
        case main(MainFeature.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    
    var body: some Reducer<State, Action> {
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.splashTimerFinished)
                }
                
            case .splashTimerFinished:
                state.route = .main
                return .none
                
            case .main:
                return .none
            }
        }
    }
}
