import Foundation

public enum CurrencyUnit: String, CaseIterable, Equatable, Identifiable, Sendable {
    case usd = "Dollar (USD)"
    case krw = "Won (KRW)"

    public var id: Self { self }

    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .krw: return "₩"
        }
    }
}
