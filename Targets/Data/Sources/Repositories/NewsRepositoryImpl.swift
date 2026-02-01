import Domain
import Entity

public final class NewsRepositoryImpl: NewsRepository {
    private let cryptopanicService: CryptoPanicDataSourceImpl

    public init(cryptopanicService: CryptoPanicDataSourceImpl) {
        self.cryptopanicService = cryptopanicService
    }

    public func fetchNews(currency: String) async throws -> [NewsArticle] {
        let responseDTO = try await cryptopanicService.fetch(currency: currency)
        print(responseDTO.results)
        return responseDTO.results.compactMap { $0.toEntity() }
    }
}
