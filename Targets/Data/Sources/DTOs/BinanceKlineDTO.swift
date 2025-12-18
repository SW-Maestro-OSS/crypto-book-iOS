//
//  BinanceKlineDTO.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

/// Binance Kline (OHLCV) DTO
/// Response shape (array):
/// [
///   0 openTime,
///   1 open,
///   2 high,
///   3 low,
///   4 close,
///   5 volume,
///   6 closeTime,
///   7 quoteAssetVolume,
///   8 numberOfTrades,
///   9 takerBuyBaseAssetVolume,
///   10 takerBuyQuoteAssetVolume,
///   11 ignore
/// ]
struct BinanceKlineDTO: Decodable {

    let openTime: Int64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String
    let closeTime: Int64

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        self.openTime = try container.decode(Int64.self)
        self.open = try container.decode(String.self)
        self.high = try container.decode(String.self)
        self.low = try container.decode(String.self)
        self.close = try container.decode(String.self)
        self.volume = try container.decode(String.self)
        self.closeTime = try container.decode(Int64.self)

        _ = try? container.decode(String.self) // quoteAssetVolume
        _ = try? container.decode(Int.self)    // numberOfTrades
        _ = try? container.decode(String.self) // takerBuyBaseAssetVolume
        _ = try? container.decode(String.self) // takerBuyQuoteAssetVolume
        _ = try? container.decode(String.self) // ignore
    }
}

extension BinanceKlineDTO {

    func toDomain() -> OHLCV? {
        guard
            let open = Double(open),
            let high = Double(high),
            let low = Double(low),
            let close = Double(close),
            let volume = Double(volume)
        else {
            return nil
        }

        return OHLCV(
            openTime: Date(timeIntervalSince1970: TimeInterval(openTime) / 1000),
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
