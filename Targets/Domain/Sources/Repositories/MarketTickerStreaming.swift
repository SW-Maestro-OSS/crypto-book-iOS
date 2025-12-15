//
//  MarketTickerStreaming.swift
//  Domain
//
//  Created by 김정원 on 12/15/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public protocol MarketTickerStreaming {
    func connect() -> AsyncThrowingStream<[MarketTicker], Error>
    func disconnect()
}
