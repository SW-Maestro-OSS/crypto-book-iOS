//
//  MarketTickerDTO.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity 

public struct MarketTickerDTO: Decodable {
    public let e: String     // Event type
    public let E: Int        // Event time
    public let s: String     // Symbol
    public let p: String     // Price change
    public let P: String     // Price change percent
    public let w: String     // Weighted average price
    public let c: String     // Last price
    public let Q: String     // Last quantity
    public let o: String     // Open price
    public let h: String     // High price
    public let l: String     // Low price
    public let v: String     // Base volume
    public let q: String     // Quote volume
    public let O: Int        // Open time
    public let C: Int        // Close time
    public let F: Int        // First trade ID
    public let L: Int        // Last trade ID
    public let n: Int        // Total trades
    
    public func toDomain() -> MarketTicker {
        let iconURL: String?
        if s.hasSuffix("USDT") {
            let baseSymbol = s.dropLast(4).lowercased()
            iconURL = "https://static.coincap.io/assets/icons/\(baseSymbol)@2x.png"
        } else {
            iconURL = nil
        }

        return MarketTicker(
            symbol: s,
            iconURL: iconURL,
            priceChange: Double(p) ?? 0,
            priceChangePercent: Double(P) ?? 0,
            weightedAvgPrice: Double(w) ?? 0,
            lastPrice: Double(c) ?? 0,
            highPrice: Double(h) ?? 0,
            lowPrice: Double(l) ?? 0,
            volume: Double(v) ?? 0,
            quoteVolume: Double(q) ?? 0
        )
    }
}

