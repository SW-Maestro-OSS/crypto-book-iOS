//
//  BinanceKlineDTO.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

/// Binance Kline (Candle) DTO
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
public struct BinanceKlineDTO: Decodable {
    public let eventType: String
    public let eventTime: Int64
    public let symbol: String
    public let kline: KlineData
    
    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case kline = "k"
    }
    
    public struct KlineData: Decodable {
        public let startTime: Int64
        public let closeTime: Int64
        public let interval: String
        public let open: String
        public let close: String
        public let high: String
        public let low: String
        public let volume: String
        public let isFinal: Bool
        
        enum CodingKeys: String, CodingKey {
            case startTime = "t"
            case closeTime = "T"
            case interval = "i"
            case open = "o"
            case close = "c"
            case high = "h"
            case low = "l"
            case volume = "v"
            case isFinal = "x" // 이 값이 true일 때 캔들이 확정됨
        }
    }
}

extension BinanceKlineDTO {
    
    public func toDomain() -> Candle? {
        let data = self.kline

        guard
            let open = Double(data.open),
            let high = Double(data.high),
            let low = Double(data.low),
            let close = Double(data.close),
            let volume = Double(data.volume)
        else {
            return nil
        }

        return Candle(
            openTimeMs: data.startTime,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
