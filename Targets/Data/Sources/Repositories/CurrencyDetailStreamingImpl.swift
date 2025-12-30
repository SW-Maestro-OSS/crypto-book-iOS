//
//  CurrencyDetailStreamingImpl.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain

public final class CurrencyDetailStreamingImpl: CurrencyDetailStreaming, @unchecked Sendable {

    private let remoteDataSource: CurrencyDetailRemoteDataSource

    public init() {
        self.remoteDataSource = BinanceCurrencyDetailWebSocketService()
    }

    init(remoteDataSource: CurrencyDetailRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error> {
        remoteDataSource.connect(symbol: symbol)
    }

    public func disconnect() {
        remoteDataSource.disconnect()
    }
}
