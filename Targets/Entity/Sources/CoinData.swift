import Foundation

/// Represents basic information about a cryptocurrency coin.
public struct CoinData {
    /// The name of the cryptocurrency.
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
