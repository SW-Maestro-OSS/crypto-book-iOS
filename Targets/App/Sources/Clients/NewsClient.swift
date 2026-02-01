import ComposableArchitecture
import Entity
import Foundation

@DependencyClient
struct NewsClient {
    var fetchNews: @Sendable (String) async throws -> [NewsArticle]
}
