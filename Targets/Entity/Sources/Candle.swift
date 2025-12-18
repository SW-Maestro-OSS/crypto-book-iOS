//
//  Candle.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation

public struct Candle: Equatable, Identifiable {
    public var id: Int64 { openTimeMs }

    public let openTimeMs: Int64
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    /// Base-asset volume for the interval.
    public let volume: Double

    public init(
        openTimeMs: Int64,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) {
        self.openTimeMs = openTimeMs
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}
