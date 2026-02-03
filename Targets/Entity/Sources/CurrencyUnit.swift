import Foundation

public enum CurrencyUnit: String, CaseIterable, Equatable, Identifiable, Sendable {
    case usd
    case krw

    public var id: Self { self }

    public var symbol: String {
        switch self {
        case .usd: return "$"
        case .krw: return "₩"
        }
    }

    public var displayName: String {
        switch self {
        case .usd: return "Dollar (USD)"
        case .krw: return "Won (KRW)"
        }
    }
}
