//
//  CurrencyDetailStreamingClient.swift
//  CryptoBook
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import ComposableArchitecture
import Factory
import Domain
import Entity

struct CurrencyDetailStreamingClient {
  var connect: @Sendable (String) -> AsyncThrowingStream<CurrencyDetailTick, Error>
  var disconnect: @Sendable () -> Void
}

// MARK: - DependencyKey

extension CurrencyDetailStreamingClient: DependencyKey {
    static let liveValue: Self = {
        @Injected(\.currencyDetailStreamingClient) var client
        return client
    }()
}

// MARK: - DependencyValues

extension DependencyValues {
    var currencyDetailStreaming: CurrencyDetailStreamingClient {
        get { self[CurrencyDetailStreamingClient.self] }
        set { self[CurrencyDetailStreamingClient.self] = newValue }
    }
}
