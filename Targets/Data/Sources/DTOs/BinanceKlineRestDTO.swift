//
//  BinanceKlineRestDTO.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public struct BinanceKlineRestDTO: Decodable {
    public let openTime: Int64
    public let open: String
    public let high: String
    public let low: String
    public let close: String
    public let volume: String

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.openTime = try container.decode(Int64.self)
        self.open = try container.decode(String.self)
        self.high = try container.decode(String.self)
        self.low = try container.decode(String.self)
        self.close = try container.decode(String.self)
        self.volume = try container.decode(String.self)
    }

    public func toDomain() -> Candle? {
        guard let o = Double(open), let h = Double(high),
              let l = Double(low), let c = Double(close),
              let v = Double(volume) else { return nil }

        return Candle(
            openTimeMs: openTime,
            open: o, high: h, low: l, close: c, volume: v
        )
    }
}
