import Foundation

public enum PriceFormatter {
    /// Formats a price value based on the selected currency and exchange rate.
    /// - Parameters:
    ///   - price: The price in USD
    ///   - currency: The target currency unit
    ///   - exchangeRate: The USD to KRW exchange rate (required when currency is .krw)
    /// - Returns: Formatted price string with currency symbol
    public static func format(
        price: Double,
        currency: CurrencyUnit,
        exchangeRate: Double?
    ) -> String {
        switch currency {
        case .usd:
            return String(format: "$%.4f", price)
        case .krw:
            guard let rate = exchangeRate else {
                return "₩---"
            }
            let krwPrice = price * rate
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            let formatted = formatter.string(from: NSNumber(value: krwPrice)) ?? "---"
            return "₩\(formatted)"
        }
    }
}
