import Foundation
import Entity

struct FetchKlinesClient {
    var execute: @Sendable (_ symbol: String, _ interval: String, _ limit: Int) async throws -> [Candle]
}
