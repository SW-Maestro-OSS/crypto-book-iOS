import Foundation
import Entity

public struct CryptopanicResponseDTO: Decodable {
    public let next: String?
    public let previous: String?
    public let results: [NewsPostDTO]
}

public struct NewsPostDTO: Decodable {
    public let id: Int
    public let slug: String
    public let title: String
    public let description: String?
    public let publishedAt: String
    public let createdAt: String
    public let kind: String

    enum CodingKeys: String, CodingKey {
        case id, slug, title, description, kind
        case publishedAt = "published_at"
        case createdAt = "created_at"
    }
}

extension NewsPostDTO {
    func toEntity() -> NewsArticle? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var date: Date?
        if let parsed = formatter.date(from: publishedAt) {
            date = parsed
        } else {
            formatter.formatOptions = [.withInternetDateTime]
            date = formatter.date(from: publishedAt)
        }

        guard let publishedDate = date else { return nil }

        // Construct URL from slug
        guard let url = URL(string: "https://cryptopanic.com/news/\(slug)/") else {
            return nil
        }

        return NewsArticle(title: title, date: publishedDate, originalURL: url)
    }
}
