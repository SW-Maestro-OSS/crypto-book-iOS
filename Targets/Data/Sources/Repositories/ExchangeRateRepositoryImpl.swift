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
        var date = Date()
        let calendar = Calendar.current

        for _ in 0..<7 {
            let rates = try await remoteDataSource.fetchExchangeRates(date: date)

            if let usdRateDTO = rates.first(where: { $0.currencyUnit == "USD" }) {
                let rateString = usdRateDTO.dealBasisRate.replacingOccurrences(of: ",", with: "")
                guard let rate = Double(rateString) else {
                    throw ExchangeRateError.parsingFailed
                }
                return rate
            }

            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }

        throw ExchangeRateError.usdRateNotFound
    }

    public enum ExchangeRateError: Error {
        case usdRateNotFound
        case parsingFailed
    }
}
