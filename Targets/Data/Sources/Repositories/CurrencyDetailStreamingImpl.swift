//
//  CurrencyDetailStreamingImpl.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain

final class CurrencyDetailStreamingImpl: CurrencyDetailStreaming, @unchecked Sendable {

    private let service: BinanceCurrencyDetailWebSocketService

    init(service: BinanceCurrencyDetailWebSocketService = BinanceCurrencyDetailWebSocketService()) {
        self.service = service
    }

    func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error> {
        service.connect(symbol: symbol)
    }

    func disconnect() {
        service.disconnect()
    }
}
