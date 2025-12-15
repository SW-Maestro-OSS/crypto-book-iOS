//
//  MarketTicker.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation

public struct MarketTicker: Equatable, Sendable {
    public let symbol: String
    public let iconURL: String?
    public let priceChange: Double
    public let priceChangePercent: Double
    public let weightedAvgPrice: Double
    public let lastPrice: Double
    public let highPrice: Double
    public let lowPrice: Double
    public let volume: Double
    public let quoteVolume: Double

    public init(
        symbol: String,
        iconURL: String?,
        priceChange: Double,
        priceChangePercent: Double,
        weightedAvgPrice: Double,
        lastPrice: Double,
        highPrice: Double,
        lowPrice: Double,
        volume: Double,
        quoteVolume: Double
    ) {
        self.symbol = symbol
        self.iconURL = iconURL
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.weightedAvgPrice = weightedAvgPrice
        self.lastPrice = lastPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.volume = volume
        self.quoteVolume = quoteVolume
    }
}
