import Domain
import Entity

public final class NewsRepositoryImpl: NewsRepository {
    private let cryptoPanicDataSource: CryptoPanicDataSource

    public init(cryptoPanicDataSource: CryptoPanicDataSource) {
        self.cryptoPanicDataSource = cryptoPanicDataSource
    }

    public func fetchNews(currency: String) async throws -> [NewsArticle] {
        let responseDTO = try await cryptoPanicDataSource.fetch(currency: currency)
        print(responseDTO.results)
        return responseDTO.results.compactMap { $0.toEntity() }
    }
}
