import Foundation
import Entity

struct MarketTickerStreamClient {
    var stream: () -> AsyncThrowingStream<[MarketTicker], Error>
}
