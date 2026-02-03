import Foundation

protocol ExchangeRateRemoteDataSource {
    func fetchExchangeRates(date: Date) async throws -> [ExchangeRateDTO]
}
