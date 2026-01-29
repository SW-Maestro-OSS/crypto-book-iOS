import Foundation

struct ExchangeRateClient {
    var fetchUSDtoKRW: @Sendable () async throws -> Double
}
