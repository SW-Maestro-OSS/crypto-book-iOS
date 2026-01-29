import ComposableArchitecture
import Data
import Domain
import Entity
import Foundation

@DependencyClient
struct NewsClient {
    var fetchNews: @Sendable (String) async throws -> [NewsArticle]
}

extension NewsClient: DependencyKey {
    static let liveValue: Self = {
        let service = CryptopanicService()
        let repository = NewsRepositoryImpl(cryptopanicService: service)

        return Self(
            fetchNews: { currency in
                try await repository.fetchNews(currency: currency)
            }
        )
    }()

    static let testValue = Self(
        fetchNews: { _ in
            [
                NewsArticle(title: "Test News 1", date: .now, originalURL: URL(string: "https://test.com/1")!),
                NewsArticle(title: "Test News 2", date: .now, originalURL: URL(string: "https://test.com/2")!)
            ]
        }
    )
}

extension DependencyValues {
    var newsClient: NewsClient {
        get { self[NewsClient.self] }
        set { self[NewsClient.self] = newValue }
    }
}
