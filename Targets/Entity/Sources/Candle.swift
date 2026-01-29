import Foundation

/// Represents a single candle in a financial chart, typically used for OHLCV data.
public struct Candle: Equatable {
    public let openTimeMs: Int64
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
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
