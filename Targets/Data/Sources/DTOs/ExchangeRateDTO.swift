import Foundation

/// DTO for Korea Exim Bank exchange rate API response.
struct ExchangeRateDTO: Decodable {
    /// Result code (1: success, 2: no data, 3: holiday, 4: auth failed)
    let result: Int
    /// Currency unit code (e.g. "USD")
    let currencyUnit: String
    /// Deal basis rate with comma formatting (e.g. "1,362.35")
    let dealBasisRate: String

    enum CodingKeys: String, CodingKey {
        case result
        case currencyUnit = "cur_unit"
        case dealBasisRate = "deal_bas_r"
    }
}
