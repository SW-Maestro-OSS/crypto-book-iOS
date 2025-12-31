import Foundation

/// Repository for fetching currency exchange rates.
public protocol ExchangeRateRepository {
    /// Fetches the latest USD to KRW exchange rate.
    /// - Returns: The exchange rate as a Double (e.g., 1362.35)
    func fetchUSDtoKRW() async throws -> Double
}
