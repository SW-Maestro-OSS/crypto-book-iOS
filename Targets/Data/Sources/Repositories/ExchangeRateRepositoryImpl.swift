import Foundation
import Domain

public struct ExchangeRateRepositoryImpl: ExchangeRateRepository {
    private let remoteDataSource: ExchangeRateRemoteDataSource

    public init() {
        self.remoteDataSource = ExchangeRateService()
    }

    init(remoteDataSource: ExchangeRateRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchUSDtoKRW() async throws -> Double {
        let rates = try await remoteDataSource.fetchExchangeRates()

        guard let usdRateDTO = rates.first(where: { $0.currencyUnit == "USD" }) else {
            throw ExchangeRateError.usdRateNotFound
        }

        // Remove commas and convert to Double
        let rateString = usdRateDTO.dealBasisRate.replacingOccurrences(of: ",", with: "")
        guard let rate = Double(rateString) else {
            throw ExchangeRateError.parsingFailed
        }

        return rate
    }

    public enum ExchangeRateError: Error {
        case usdRateNotFound
        case parsingFailed
    }
}
