import Foundation
import Entity

struct CurrencyDetailStreamClient {
    var connect: @Sendable (String) -> AsyncThrowingStream<CurrencyDetailTick, Error>
    var disconnect: @Sendable () -> Void
}
