import ComposableArchitecture
import Data
import Domain
import Entity
import Foundation

@DependencyClient
public struct NewsClient {
    public var fetchNews: @Sendable (String) async throws -> [NewsArticle]
}

extension NewsClient: DependencyKey {
    public static let liveValue: Self = {
        let service = CryptopanicService()
        let repository = NewsRepositoryImpl(cryptopanicService: service)
        
        return Self(
            fetchNews: { currency in
                try await repository.fetchNews(currency: currency)
            }
        )
    }()
    
    public static let testValue = Self(
        fetchNews: { _ in
            [
                NewsArticle(title: "Test News 1: Bitcoin to the Moon", date: .now, originalURL: URL(string: "https://test.com/1")!),
                NewsArticle(title: "Test News 2: Ethereum's new update", date: .now.addingTimeInterval(-3600), originalURL: URL(string: "https://test.com/2")!)
            ]
        }
    )
}

extension DependencyValues {
    public var newsClient: NewsClient {
        get { self[NewsClient.self] }
        set { self[NewsClient.self] = newValue }
    }
}