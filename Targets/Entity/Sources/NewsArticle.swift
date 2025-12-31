import Foundation

/// Represents a news article related to cryptocurrencies.
public struct NewsArticle: Equatable, Identifiable {
    /// A unique identifier for the news article, derived from its original URL.
    public var id: String { originalURL.absoluteString }

    /// The title of the news article.
    public let title: String
    /// The publication date of the news article.
    public let date: Date
    /// The original URL of the news article.
    public let originalURL: URL

    public init(title: String, date: Date, originalURL: URL) {
        self.title = title
        self.date = date
        self.originalURL = originalURL
    }
}
