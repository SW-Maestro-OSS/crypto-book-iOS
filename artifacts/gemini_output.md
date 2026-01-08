# 코인 상세 화면 뉴스 기능 구현

`PROJECT.md` 명세에 따라 Cryptopanic API를 사용하여 코인 상세 화면에 관련 뉴스 목록을 표시하는 기능을 구현합니다. 데이터 레이어부터 피처 레이어까지 필요한 모든 코드를 포함합니다.

## 1. 데이터 레이어 추가 (DTO, Service)

API 통신 및 데이터 처리를 위한 DTO와 Service를 추가합니다.

**File: `Targets/Data/Sources/DTOs/CryptopanicDTO.swift` (New File)**
```swift
import Foundation
import Entity

struct CryptopanicResponseDTO: Decodable {
    let results: [NewsPostDTO]
}

struct NewsPostDTO: Decodable {
    let title: String
    let url: URL
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case title, url
        case publishedAt = "published_at"
    }
}

extension NewsPostDTO {
    func toEntity() -> NewsArticle? {
        let formatter = ISO8601DateFormatter()
        // ISO8601 날짜 형식에 유연하게 대응하기 위해 두 가지 옵션을 시도합니다.
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: publishedAt) else {
            formatter.formatOptions = [.withInternetDateTime]
            guard let dateWithoutFractionalSeconds = formatter.date(from: publishedAt) else {
                return nil
            }
            return NewsArticle(title: title, date: dateWithoutFractionalSeconds, originalURL: url)
        }
        return NewsArticle(title: title, date: date, originalURL: url)
    }
}
```

**File: `Targets/Data/Sources/Services/CryptopanicService.swift` (New File)**
```swift
import Foundation
import Infra

enum CryptopanicError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiKeyMissing
}

final class CryptopanicService {
    private let baseURL = "https://cryptopanic.com/api/v1/posts/"

    func fetchNews(currency: String) async throws -> CryptopanicResponseDTO {
        // PlistKeys를 통해 API 키를 안전하게 가져옵니다.
        guard let apiKey = PlistKeys.cryptopanicApiKey else {
            throw CryptopanicError.apiKeyMissing
        }

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "auth_token", value: apiKey),
            URLQueryItem(name: "currencies", value: currency),
            URLQueryItem(name: "public", value: "true")
        ]

        guard let url = components?.url else {
            throw CryptopanicError.invalidURL
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(CryptopanicResponseDTO.self, from: data)
            return response
        } catch let error as DecodingError {
            throw CryptopanicError.decodingError(error)
        } catch {
            throw CryptopanicError.networkError(error)
        }
    }
}
```
*(참고: 위 코드는 `Configs/Secrets.xcconfig` 파일에 `CRYPTOPANIC_API_KEY = "YOUR_API_KEY"`와 같은 설정이 이미 되어 있다고 가정합니다.)*

## 2. 도메인 및 데이터 레이어 추가 (Repository)

**File: `Targets/Domain/Sources/Repositories/NewsRepository.swift` (New File)**
```swift
import Entity

public protocol NewsRepository {
    func fetchNews(currency: String) async throws -> [NewsArticle]
}
```

**File: `Targets/Data/Sources/Repositories/NewsRepositoryImpl.swift` (New File)**
```swift
import Domain
import Entity

public final class NewsRepositoryImpl: NewsRepository {
    private let cryptopanicService: CryptopanicService

    public init(cryptopanicService: CryptopanicService) {
        self.cryptopanicService = cryptopanicService
    }

    public func fetchNews(currency: String) async throws -> [NewsArticle] {
        let response = try await cryptopanicService.fetchNews(currency: currency)
        return response.results.compactMap { $0.toEntity() }
    }
}
```

## 3. 앱 의존성 추가 (Client)

**File: `Targets/App/Sources/Dependencies/NewsClient.swift` (New File)**
```swift
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
```

## 4. `CurrencyDetailFeature` 및 `View` 수정

뉴스 데이터를 불러오고 UI에 표시하는 로직을 추가합니다.

**File: `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift` (Updated)**

```swift
// 1. Feature 최상단에 의존성을 추가합니다.
@Dependency(\.newsClient) var newsClient
@Dependency(\.openURL) var openURL

// 2. State 구조체 내부에 뉴스 관련 상태를 추가합니다.
@ObservableState
struct State: Equatable {
    // ... 기존 상태들
    var news: [NewsArticle] = []
    var isLoadingNews: Bool = false
}

// 3. Action 열거형에 뉴스 관련 액션을 추가합니다.
enum Action {
    // ... 기존 액션들
    case newsArticleTapped(URL)
    case newsResponse(Result<[NewsArticle], Error>)
}

// 4. Reducer의 onAppear 액션에 뉴스 호출 Effect를 추가합니다.
case .onAppear:
    return .merge(
        // ... 기존 Effect들
        .run { [symbol = state.symbol] send in
            state.isLoadingNews = true
            await send(.newsResponse(Result { try await newsClient.fetchNews(symbol) }))
        }
    )

// 5. Reducer에 뉴스 응답 및 탭 액션 처리 로직을 추가합니다.
case let .newsResponse(.success(articles)):
    state.isLoadingNews = false
    state.news = articles
    return .none

case let .newsResponse(.failure(error)):
    state.isLoadingNews = false
    print("News fetch error: \(error)")
    return .none

case let .newsArticleTapped(url):
    return .run { _ in
        await openURL(url)
    }
```

**File: `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailView.swift` (Updated)**

```swift
// 1. body의 VStack 내부에서 주석 처리된 newsSection을 활성화합니다.
// newsSection

// 2. View 하단에 newsSection 구현을 추가합니다.
private var newsSection: some View {
    VStack(alignment: .leading, spacing: 16) {
        Text("News")
            .font(.headline)

        if store.isLoadingNews {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else if store.news.isEmpty {
            Text("No news available.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        } else {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(store.news) { article in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(article.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(2)
                        Text(article.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        store.send(.newsArticleTapped(article.originalURL))
                    }
                }
            }
        }
    }
}
```
