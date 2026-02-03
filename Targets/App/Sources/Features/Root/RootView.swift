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
            Group {
                switch store.route {
                case .splash:
                    SplashView()
                        .onAppear {
                            store.send(.onAppear)
                        }

                case .main:
                    MainView(
                        store: store.scope(state: \.main, action: \.main)
                    )
                }
            }
            .environment(\.locale, Locale(identifier: store.main.settings.selectedLanguage.rawValue))
        }
    }
}
