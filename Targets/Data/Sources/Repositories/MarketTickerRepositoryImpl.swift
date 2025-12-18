//
//  InitialDataRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity
import Domain

final class MarketTickerRepositoryImpl: MarketTickerRepository {
    private let service: BinanceAllMarketTickersWebSocketService

    init(service: BinanceAllMarketTickersWebSocketService) {
        self.service = service
    }

    func tickerStream() -> AsyncThrowingStream<[MarketTicker], Error> {
        service.connect()
    }
}
