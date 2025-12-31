import Foundation

protocol ExchangeRateRemoteDataSource {
    func fetchExchangeRates() async throws -> [ExchangeRateDTO]
}
