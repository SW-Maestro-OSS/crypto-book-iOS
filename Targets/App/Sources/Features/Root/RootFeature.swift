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
        var splash = SplashFeature.State()
        var main = MainFeature.State()
    }

    enum Route {
        case splash
        case main
    }

    enum Action {
        case splash(SplashFeature.Action)
        case main(MainFeature.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.splash, action: \.splash) {
            SplashFeature()
        }
        Scope(state: \.main, action: \.main) {
            MainFeature()
        }

        Reduce { state, action in
            switch action {
            case .splash(.delegate(.didFinishLoading)):
                state.route = .main
                return .none

            case .splash, .main:
                return .none
            }
        }
    }
}
