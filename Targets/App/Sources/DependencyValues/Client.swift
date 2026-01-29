//
//  MarketTickerClient.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Entity

struct MarketTickerStreamClient {
    var stream: () -> AsyncThrowingStream<[MarketTicker], Error>
}

struct KlineStreamClient {
    var stream: (String, String) -> AsyncThrowingStream<Candle, Error>
}
