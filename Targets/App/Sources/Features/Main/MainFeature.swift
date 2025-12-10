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
struct MainFeature {

    @ObservableState
    struct State: Equatable {
    }

    enum Action {
        case onAppear
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 초기 로직 처리 가능 (api 호출 등)
                return .none
            }
        }
    }
}
