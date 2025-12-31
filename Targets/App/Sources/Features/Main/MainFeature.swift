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

        @Presents var destination: Destination.State?

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
        case tickerTapped(String)
        case destination(PresentationAction<Destination.Action>)
    }

    @Reducer(state: .equatable)
    enum Destination {
        case currencyDetail(CurrencyDetailFeature)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
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

            case let .tickerTapped(symbol):
                guard let ticker = state.tickers.first(where: { $0.symbol == symbol }) else {
                    return .none
                }
                let previousClosePrice = ticker.lastPrice - ticker.priceChange
                state.destination = .currencyDetail(
                    .init(
                        symbol: symbol,
                        previousClosePrice: previousClosePrice,
                        priceChange24h: ticker.priceChange,
                        changePercent24h: ticker.priceChangePercent
                    )
                )
                return .none

            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
