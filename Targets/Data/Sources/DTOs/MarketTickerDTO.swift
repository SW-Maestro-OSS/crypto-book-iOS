//
//  MarketTickerDTO.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity 

struct MarketTickerDTO: Decodable {
    let e: String     // Event type
    let E: Int        // Event time
    let s: String     // Symbol
    let p: String     // Price change
    let P: String     // Price change percent
    let w: String     // Weighted average price
    let c: String     // Last price
    let Q: String     // Last quantity
    let o: String     // Open price
    let h: String     // High price
    let l: String     // Low price
    let v: String     // Base volume
    let q: String     // Quote volume
    let O: Int        // Open time
    let C: Int        // Close time
    let F: Int        // First trade ID
    let L: Int        // Last trade ID
    let n: Int        // Total trades
    
    func toDomain() -> MarketTicker {
        MarketTicker(
            symbol: s,
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

