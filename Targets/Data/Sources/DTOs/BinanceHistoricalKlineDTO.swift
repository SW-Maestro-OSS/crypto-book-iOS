//
//  BinanceKlineRestDTO.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public struct BinanceHistoricalKlineDTO: Decodable {
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

    public func toDomain() throws -> Candle {

        guard
            let open = Double(self.open),
            let high = Double(self.high),
            let low = Double(self.low),
            let close = Double(self.close),
            let volume = Double(self.volume)
        else {
            throw DataMappingError.invalidNumberFormat
        }

        return Candle(
            openTimeMs: self.openTime,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
