import Entity

public protocol NewsRepository {
    func fetchNews(currency: String) async throws -> [NewsArticle]
}