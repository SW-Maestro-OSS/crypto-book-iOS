import Foundation

public struct NewsArticle: Equatable, Identifiable {
    public var id: String { "\(date.timeIntervalSince1970)-\(title)" }
    public let title: String
    public let date: Date

    public init(title: String, date: Date) {
        self.title = title
        self.date = date
    }
}
