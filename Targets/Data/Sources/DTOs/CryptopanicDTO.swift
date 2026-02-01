import Foundation
import Entity

/// Cryptopanic API의 뉴스 응답을 나타내는 데이터 전송 객체입니다.
public struct CryptoPanicResponseDTO: Decodable {
    /// 다음 페이지 URL
    public let next: String?
    /// 이전 페이지 URL
    public let previous: String?
    /// 뉴스 게시물 목록
    public let results: [CryptoPanicPostDTO]
}

/// Cryptopanic API의 개별 뉴스 게시물을 나타내는 데이터 전송 객체입니다.
public struct CryptoPanicPostDTO: Decodable {
    public let id: Int?
    public let title: String
    public let description: String?
    public let url: String?
    public let publishedAt: String
    public let createdAt: String
    public let kind: String
    public let domain: String?
    public let source: CryptoPanicSourceDTO?
    public let currencies: [CryptoPanicCurrencyDTO]?
    public let votes: CryptoPanicVotesDTO?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case url
        case publishedAt = "published_at"
        case createdAt   = "created_at"
        case kind
        case domain
        case source
        case currencies
        case votes
    }
}

/// 뉴스 출처 정보를 담는 데이터 전송 객체입니다.
public struct CryptoPanicSourceDTO: Decodable {
    public let title: String?
    public let region: String?
    public let domain: String?
}

/// 뉴스에 언급된 암호화폐 정보를 담는 데이터 전송 객체입니다.
public struct CryptoPanicCurrencyDTO: Decodable {
    public let code: String
    public let title: String?
    public let slug: String?
}

/// 뉴스에 대한 투표 정보를 담는 데이터 전송 객체입니다.
public struct CryptoPanicVotesDTO: Decodable {
    public let negative: Int?
    public let positive: Int?
    public let important: Int?
    public let liked: Int?
    public let disliked: Int?
    public let lol: Int?
    public let toTheMoon: Int?

    enum CodingKeys: String, CodingKey {
        case negative
        case positive
        case important
        case liked
        case disliked
        case lol
        case toTheMoon = "to_the_moon"
    }
}

// MARK: - Mappers
extension CryptoPanicPostDTO {
    /// DTO를 `NewsArticle` 도메인 엔티티로 변환합니다.
    /// - Returns: 변환된 `NewsArticle` 객체. 변환 실패 시 `nil`을 반환합니다.
    func toEntity() -> NewsArticle? {
        let formatter = ISO8601DateFormatter()

        func parseDate(from string: String) -> Date? {
            // 밀리초를 포함하는 포맷 먼저 시도
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: string) {
                return date
            }
            
            // 밀리초가 없는 포맷으로 다시 시도
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: string) {
                return date
            }
            
            return nil
        }

        guard let publishedDate = parseDate(from: publishedAt) else { return nil }
        
        return NewsArticle(
            title: title,
            date: publishedDate
        )
    }
}
