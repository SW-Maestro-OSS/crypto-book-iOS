//
//  RootFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Domain
import Entity

enum MainSortKey: Equatable {
    case symbol
    case price
    case changePercent
}

enum MainSortOrder: Equatable {
    case ascending
    case descending
}

@Reducer
struct MainFeature {

    @ObservableState
    struct State: Equatable {
        var tickers: [MarketTicker] = []
        var sortKey: MainSortKey? = nil
        var sortOrder: MainSortOrder = .ascending
        var visibleCount: Int = 10

        // Derived collections for presentation
        var top30Tickers: [MarketTicker] {
            tickers
                .sorted { $0.quoteVolume > $1.quoteVolume }
                .prefix(30)
                .map { $0 }
        }

        var sortedTickers: [MarketTicker] {
            guard let sortKey else { return top30Tickers }

            switch sortKey {
            case .symbol:
                return top30Tickers.sorted { lhs, rhs in
                    sortOrder == .ascending ? (lhs.symbol < rhs.symbol) : (lhs.symbol > rhs.symbol)
                }

            case .price:
                return top30Tickers.sorted { lhs, rhs in
                    sortOrder == .ascending ? (lhs.lastPrice < rhs.lastPrice) : (lhs.lastPrice > rhs.lastPrice)
                }

            case .changePercent:
                return top30Tickers.sorted { lhs, rhs in
                    sortOrder == .ascending ? (lhs.priceChangePercent < rhs.priceChangePercent) : (lhs.priceChangePercent > rhs.priceChangePercent)
                }
            }
        }

        var visibleTickers: [MarketTicker] {
            Array(sortedTickers.prefix(visibleCount))
        }
    }

    enum Action {
        case onAppear
        case tickersUpdated([MarketTicker])
        case sortBySymbolTapped
        case sortByPriceTapped
        case sortByChangeTapped
        case showMoreTapped
    }

    @Dependency(\.marketTicker) var marketTicker
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        for try await tickers in marketTicker.stream() {
                            await send(.tickersUpdated(tickers))
                        }
                    } catch {
                        // TODO: 에러 처리 (예: 로깅, 상태 반영 등)
                        print("⚠️ marketTicker stream error:", error)
                    }
                }
            case let .tickersUpdated(tickers):
                state.tickers = tickers
                return .none

            case .sortBySymbolTapped:
                if state.sortKey == .symbol {
                    state.sortOrder = state.sortOrder == .ascending ? .descending : .ascending
                } else {
                    state.sortKey = .symbol
                    state.sortOrder = .ascending
                }
                return .none

            case .sortByPriceTapped:
                if state.sortKey == .price {
                    state.sortOrder = state.sortOrder == .ascending ? .descending : .ascending
                } else {
                    state.sortKey = .price
                    state.sortOrder = .ascending
                }
                return .none

            case .sortByChangeTapped:
                if state.sortKey == .changePercent {
                    state.sortOrder = state.sortOrder == .ascending ? .descending : .ascending
                } else {
                    state.sortKey = .changePercent
                    state.sortOrder = .ascending
                }
                return .none

            case .showMoreTapped:
                state.visibleCount = 30
                return .none
            }
        }
    }
}
