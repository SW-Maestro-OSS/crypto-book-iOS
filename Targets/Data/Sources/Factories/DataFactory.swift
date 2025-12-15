//
//  DataFactory.swift
//  Data
//
//  Created by 김정원 on 12/15/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain

public enum DataFactory {
    public static func makeMarketTickerRepository() -> any MarketTickerRepository {
        MarketTickerRepositoryImpl(
            service: BinanceAllMarketTickersWebSocketService.shared
        )
    }
}
