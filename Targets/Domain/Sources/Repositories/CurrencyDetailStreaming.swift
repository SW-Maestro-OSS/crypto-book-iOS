//
//  CurrencyDetailStreaming.swift
//  Domain
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public protocol CurrencyDetailStreaming: Sendable {
    func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error>
    func disconnect()
}

/// 디테일 헤더에 필요한 실시간 값만 먼저
public struct CurrencyDetailTick: Equatable, Sendable {
    public let symbol: String
    public let midPrice: Double?           // bookTicker
    public let changePercent24h: Double?   // 24hr ticker
}
