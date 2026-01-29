import Foundation
import Entity

struct KlineStreamClient {
    var stream: @Sendable (_ symbol: String, _ interval: String) -> AsyncThrowingStream<Candle, Error>
}
