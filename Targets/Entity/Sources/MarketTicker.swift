import Foundation

/// Represents the market ticker information for a specific cryptocurrency.
public struct MarketTicker: Equatable, Sendable {
    /// The trading symbol (e.g., "BTCUSDT").
    public let symbol: String
    /// The URL for the coin's icon.
    public let iconURL: String?
    /// The change in price over the last 24 hours.
    public let priceChange: Double
    /// The percentage change in price over the last 24 hours.
    public let priceChangePercent: Double
    /// The weighted average price over the last 24 hours.
    public let weightedAvgPrice: Double
    /// The last traded price.
    public let lastPrice: Double
    /// The highest price in the last 24 hours.
    public let highPrice: Double
    /// The lowest price in the last 24 hours.
    public let lowPrice: Double
    /// The total trading volume in the last 24 hours.
    public let volume: Double
    /// The total quote asset volume in the last 24 hours.
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
