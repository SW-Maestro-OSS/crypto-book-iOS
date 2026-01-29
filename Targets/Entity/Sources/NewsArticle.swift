import Foundation

public struct NewsArticle: Equatable {
    public let title: String
    public let date: Date
    public let originalURL: URL

    public init(title: String, date: Date, originalURL: URL) {
        self.title = title
        self.date = date
        self.originalURL = originalURL
    }
}
