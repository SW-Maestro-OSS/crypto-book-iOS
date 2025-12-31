import Foundation
import Infra

struct ExchangeRateService: ExchangeRateRemoteDataSource {
    
    private var apiKey: String {
        PlistKeys.apiKey
    }

    func fetchExchangeRates() async throws -> [ExchangeRateDTO] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let searchDate = dateFormatter.string(from: Date())
        
        let urlString = "https://www.koreaexim.go.kr/site/program/financial/exchangeJSON?authkey=\(apiKey)&searchdate=\(searchDate)&data=AP01"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let rates = try JSONDecoder().decode([ExchangeRateDTO].self, from: data)
        return rates
    }
}
