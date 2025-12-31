import Foundation

/// Represents a single candle in a financial chart, typically used for OHLCV data.
public struct Candle: Equatable, Identifiable {
    /// The unique identifier for the candle, based on the opening time.
    public var id: Int64 { openTimeMs }

    /// The timestamp of when the candle opened, in milliseconds.
    public let openTimeMs: Int64
    /// The opening price.
    public let open: Double
    /// The highest price during the candle's timeframe.
    public let high: Double
    /// The lowest price during the candle's timeframe.
    public let low: Double
    /// The closing price.
    public let close: Double
    /// The volume of the asset traded during the candle's timeframe.
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
