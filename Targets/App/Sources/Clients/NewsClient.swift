import Entity
import Foundation

struct NewsClient {
    var fetchNews: @Sendable (String) async throws -> [NewsArticle]
}
