//
//  RootView.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct RootView: View {
    @Perception.Bindable var store: StoreOf<RootFeature>

    var body: some View {
        WithPerceptionTracking {
            switch store.route {
            case .splash:
                SplashView(
                    store: store.scope(state: \.splash, action: \.splash)
                )
            case .main:
                MainView(
                    store: store.scope(state: \.main, action: \.main)
                )
            }
        }
    }
}
