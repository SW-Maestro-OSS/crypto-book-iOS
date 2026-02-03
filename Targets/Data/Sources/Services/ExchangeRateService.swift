import Foundation

struct ExchangeRateService: ExchangeRateRemoteDataSource {
    
    enum ExchangeRateError: Error {
        case apiKeyMissing
        case invalidURL
    }

    func fetchExchangeRates(date: Date) async throws -> [ExchangeRateDTO] {

        let endpoint = ExchangeRateEndpoint.fetchRates(date: date)
        
        guard let request = try? endpoint.asURLRequest() else {
            throw ExchangeRateError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let rates = try JSONDecoder().decode([ExchangeRateDTO].self, from: data)
        return rates
    }
}
