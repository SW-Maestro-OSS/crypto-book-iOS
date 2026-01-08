import Domain
import Entity

public final class NewsRepositoryImpl: NewsRepository {
    private let cryptopanicService: CryptopanicService

    public init(cryptopanicService: CryptopanicService) {
        self.cryptopanicService = cryptopanicService
    }

    public func fetchNews(currency: String) async throws -> [NewsArticle] {
        let response = try await cryptopanicService.fetchNews(currency: currency)
        return response.results.compactMap { $0.toEntity() }
    }
}