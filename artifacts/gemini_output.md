# Entity 모델 및 파일 이름 리팩토링

## 파일 이름 변경

`NewsItem.swift` 파일 이름을 `NewsArticle.swift`로 변경합니다.

```sh
mv Targets/Entity/Sources/NewsItem.swift Targets/Entity/Sources/NewsArticle.swift
```

## 파일 내용 변경

### `Targets/Entity/Sources/Candle.swift`

`OHLCV` 구조체를 `Candle`로 변경하고 Swift-Doc 주석을 추가합니다.

```swift
import Foundation

/// Represents a single candle in a financial chart, typically used for OHLCV data.
public struct Candle: Equatable, Identifiable {
    /// The unique identifier for the candle, based on the opening time.
    public var id: Int64 { openTimeMs }

    /// The timestamp of when the candle opened, in milliseconds.
    public let openTimeMs: Int64
    /// The opening price.
    public let open: Double
    /// The highest price during the candle's timeframe.
    public let high: Double
    /// The lowest price during the candle's timeframe.
    public let low: Double
    /// The closing price.
    public let close: Double
    /// The volume of the asset traded during the candle's timeframe.
    public let volume: Double

    public init(
        openTimeMs: Int64,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) {
        self.openTimeMs = openTimeMs
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}
```

### `Targets/Entity/Sources/NewsArticle.swift` (기존 `NewsItem.swift`)

파일 상단의 주석을 제거하고 Swift-Doc 주석을 추가합니다.

```swift
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
```

### `Targets/Entity/Sources/CoinData.swift`

파일 상단의 주석을 제거하고 Swift-Doc 주석을 추가합니다.

```swift
import Foundation

/// Represents basic information about a cryptocurrency coin.
public struct CoinData {
    /// The name of the cryptocurrency.
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
```

### `Targets/Entity/Sources/MarketTicker.swift`

파일 상단의 주석을 제거하고 Swift-Doc 주석을 추가합니다.

```swift
import Foundation

/// Represents the market ticker information for a specific cryptocurrency.
public struct MarketTicker: Equatable, Sendable {
    /// The trading symbol (e.g., "BTCUSDT").
    public let symbol: String
    /// The URL for the coin's icon.
    public let iconURL: String?
    /// The change in price over the last 24 hours.
    public let priceChange: Double
    /// The percentage change in price over the last 24 hours.
    public let priceChangePercent: Double
    /// The weighted average price over the last 24 hours.
    public let weightedAvgPrice: Double
    /// The last traded price.
    public let lastPrice: Double
    /// The highest price in the last 24 hours.
    public let highPrice: Double
    /// The lowest price in the last 24 hours.
    public let lowPrice: Double
    /// The total trading volume in the last 24 hours.
    public let volume: Double
    /// The total quote asset volume in the last 24 hours.
    public let quoteVolume: Double

    public init(
        symbol: String,
        iconURL: String?,
        priceChange: Double,
        priceChangePercent: Double,
        weightedAvgPrice: Double,
        lastPrice: Double,
        highPrice: Double,
        lowPrice: Double,
        volume: Double,
        quoteVolume: Double
    ) {
        self.symbol = symbol
        self.iconURL = iconURL
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.weightedAvgPrice = weightedAvgPrice
        self.lastPrice = lastPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.volume = volume
        self.quoteVolume = quoteVolume
    }
}
```

### `Targets/App/Sources/Dependencies/BinanceAPIClient.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceAPIClient.swift
//  CryptoBook
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Factory
import Entity

struct BinanceAPIClient {
    var fetchKlines: @Sendable (_ symbol: String, _ interval: String, _ limit: Int) async throws -> [Candle]
}

// MARK: - DependencyKey

extension BinanceAPIClient: DependencyKey {
    static let liveValue: Self = {
        @Injected(\.binanceApiRepository) var repository
        
        return Self(
            fetchKlines: { symbol, interval, limit in
                try await repository.fetchKlines(symbol: symbol, interval: interval, limit: limit)
            }
        )
    }()
}

// MARK: - DependencyValues

extension DependencyValues {
    var binanceAPIClient: BinanceAPIClient {
        get { self[BinanceAPIClient.self] }
        set { self[BinanceAPIClient.self] = newValue }
    }
}
```

### `Targets/App/Sources/Features/CurrencyDetail/CurrencyDetailFeature.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  CurrencyDetailFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Entity
import Domain

@Reducer
struct CurrencyDetailFeature {

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        let symbol: String

        // Header (live-ish)
        var midPrice: Double?
        var changePercent24h: Double?
        var lastUpdated: Date?

        // Chart (snapshot)
        var candles: [Candle] = []
        var chartLoading: Bool = false
        var chartError: String?

        // AI Insight (placeholder)
        var insight: Insight?
        var insightLoading: Bool = false

        // News
        var news: [NewsArticle] = []
        var newsLoading: Bool = false
        var newsError: String?

        // View
        var isFirstAppear: Bool = true

        init(symbol: String) {
            self.symbol = symbol
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case onDisappear

        // Header live updates (from WS)
        case midPriceUpdated(Double)
        case changePercent24hUpdated(Double)
        case tickReceived(CurrencyDetailTick)

        // Chart
        case fetchChart
        case chartResponse(Result<[Candle], ChartError>)

        // News
        case fetchNews
        case newsResponse(Result<[NewsArticle], NewsError>)

        // Insight
        case computeInsight
        case insightComputed(Insight)

        // UI
        case refreshPulled
        case newsItemTapped(NewsArticle)
    }

    // MARK: - Errors

    enum ChartError: Error, Equatable {
        case network(String)
    }

    enum NewsError: Error, Equatable {
        case network(String)
    }

    enum CancelID {
        case detailSocket
    }

    // MARK: - Models

    struct Insight: Equatable {
        let buyPercent: Int
        let sellPercent: Int
        let bullets: [String]

        init(buyPercent: Int, sellPercent: Int, bullets: [String]) {
            self.buyPercent = buyPercent
            self.sellPercent = sellPercent
            self.bullets = bullets
        }
    }

    // MARK: - Reducer
    @Dependency(\.currencyDetailStreaming) var streaming

    init() {}

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.isFirstAppear else { return .none }
                state.isFirstAppear = false

                // Kick off snapshot fetches.
                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews),
                    .send(.computeInsight),
                    .run { [symbol = state.symbol] send in
                        do {
                            for try await tick in streaming.connect(symbol) {
                                await send(.tickReceived(tick))
                            }
                        } catch {
                            // Swallow streaming errors for now; UI can stay on last known values.
                        }
                    }
                    .cancellable(id: CancelID.detailSocket, cancelInFlight: true)
                )

            case .onDisappear:
                streaming.disconnect()
                return .cancel(id: CancelID.detailSocket)

            // MARK: Live header updates
            case let .midPriceUpdated(value):
                state.midPrice = value
                state.lastUpdated = Date()
                return .none

            case let .changePercent24hUpdated(value):
                state.changePercent24h = value
                state.lastUpdated = Date()
                return .none

            case let .tickReceived(tick):
                if let mid = tick.midPrice {
                    state.midPrice = mid
                }
                if let change = tick.changePercent24h {
                    state.changePercent24h = change
                }
                state.lastUpdated = Date()
                return .none

            // MARK: Chart
            case .fetchChart:
                state.chartLoading = true
                state.chartError = nil

                // TODO: Replace with real REST call (e.g. /api/v3/uiKlines interval=1d limit=7)
                // For now, return empty to keep structure.
                return .send(.chartResponse(.success([])))

            case let .chartResponse(.success(candles)):
                state.chartLoading = false
                state.candles = candles
                return .send(.computeInsight)

            case let .chartResponse(.failure(error)):
                state.chartLoading = false
                state.chartError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            // MARK: News
            case .fetchNews:
                state.newsLoading = true
                state.newsError = nil

                // TODO: Replace with real CryptoPanic fetch
                return .send(.newsResponse(.success([])))

            case let .newsResponse(.success(items)):
                state.newsLoading = false
                state.news = items
                return .send(.computeInsight)

            case let .newsResponse(.failure(error)):
                state.newsLoading = false
                state.newsError = {
                    switch error {
                    case let .network(message): return message
                    }
                }()
                return .none

            // MARK: Insight
            case .computeInsight:
                // Very small rule-based placeholder:
                state.insightLoading = true

                let insight = Self.makePlaceholderInsight(
                    symbol: state.symbol,
                    candles: state.candles,
                    news: state.news
                )
                return .send(.insightComputed(insight))

            case let .insightComputed(insight):
                state.insightLoading = false
                state.insight = insight
                return .none

            // MARK: UI
            case .refreshPulled:
                return .merge(
                    .send(.fetchChart),
                    .send(.fetchNews)
                )

            case .newsItemTapped:
                // The View should handle opening the URL (system browser).
                return .none
            }
        }
    }

    // MARK: - Helpers

    static func makePlaceholderInsight(
        symbol: String,
        candles: [Candle],
        news: [NewsArticle]
    ) -> Insight {
        var buy = 50
        var sell = 50

        if let first = candles.first, let last = candles.last {
            if last.close > first.open {
                buy = 70
                sell = 30
            } else if last.close < first.open {
                buy = 30
                sell = 70
            }
        }

        var bullets: [String] = []
        bullets.append("현재 \(symbol)의 추세를 기반으로 한 간단 분석입니다.")

        if !candles.isEmpty {
            bullets.append("최근 7일(1D) 캔들 흐름을 반영했습니다.")
        }

        if !news.isEmpty {
            bullets.append("관련 뉴스 신호를 함께 고려했습니다.")
        } else {
            bullets.append("현재는 뉴스 데이터가 없어 차트 중심으로 판단합니다.")
        }

        return Insight(buyPercent: buy, sellPercent: sell, bullets: bullets)
    }
}
```

### `Targets/Data/Sources/DTOs/BinanceKlineDTO.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceKlineDTO.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

/// Binance Kline (Candle) DTO
/// Response shape (array):
/// [
///   0 openTime,
///   1 open,
///   2 high,
///   3 low,
///   4 close,
///   5 volume,
///   6 closeTime,
///   7 quoteAssetVolume,
///   8 numberOfTrades,
///   9 takerBuyBaseAssetVolume,
///   10 takerBuyQuoteAssetVolume,
///   11 ignore
/// ]
public struct BinanceKlineDTO: Decodable {
    public let eventType: String
    public let eventTime: Int64
    public let symbol: String
    public let kline: KlineData
    
    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case kline = "k"
    }
    
    public struct KlineData: Decodable {
        public let startTime: Int64
        public let closeTime: Int64
        public let interval: String
        public let open: String
        public let close: String
        public let high: String
        public let low: String
        public let volume: String
        public let isFinal: Bool
        
        enum CodingKeys: String, CodingKey {
            case startTime = "t"
            case closeTime = "T"
            case interval = "i"
            case open = "o"
            case close = "c"
            case high = "h"
            case low = "l"
            case volume = "v"
            case isFinal = "x" // 이 값이 true일 때 캔들이 확정됨
        }
    }
}

extension BinanceKlineDTO {
    
    public func toDomain() -> Candle? {
        let data = self.kline
        
        guard
            let open = Double(data.open),
            let high = Double(data.high),
            let low = Double(data.low),
            let close = Double(data.close),
            let volume = Double(data.volume)
        else {
            return nil
        }
        
        return Candle(
            openTimeMs: data.startTime, // DTO의 't' 필드 매핑
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}
```

### `Targets/Data/Sources/DTOs/BinanceKlineRestDTO.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceKlineRestDTO.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

struct BinanceKlineRestDTO: Decodable {
    let openTime: Int64
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.openTime = try container.decode(Int64.self)
        self.open = try container.decode(String.self)
        self.high = try container.decode(String.self)
        self.low = try container.decode(String.self)
        self.close = try container.decode(String.self)
        self.volume = try container.decode(String.self)
    }

    func toDomain() -> Candle? {
        guard let o = Double(open), let h = Double(high),
              let l = Double(low), let c = Double(close),
              let v = Double(volume) else { return nil }
        
        return Candle(
            openTimeMs: openTime,
            open: o, high: h, low: l, close: c, volume: v
        )
    }
}
```

### `Targets/Data/Sources/Repositories/BinanceApiRepositoryImpl.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceApiRepositoryImpl.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain
import Entity

public final class BinanceApiRepositoryImpl: BinanceApiRepository {
    private let remoteDataSource: BinanceApiRemoteDataSource

    public init() {
        self.remoteDataSource = BinanceApiService()
    }

    init(remoteDataSource: BinanceApiRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [Candle] {
        let dtos = try await remoteDataSource.fetchKlines(
            symbol: symbol,
            interval: interval,
            limit: limit
        )
        return dtos.compactMap { $0.toDomain() }
    }
}
```

### `Targets/Data/Sources/Services/BinanceCandlestickWebSocketService.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceCandlestickWebSocketService.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Combine
import Entity

final class BinanceCandlestickStreamingWebSocketService {
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func connect(symbol: String, interval: String) -> AsyncThrowingStream<[Candle], Error> {
        // 바이낸스 웹소켓 URL 구조: wss://fstream.binance.com/ws/<symbol>@kline_<interval>
        let urlString = "wss://fstream.binance.com/ws/\(symbol.lowercased())@kline_\(interval)"
        guard let url = URL(string: urlString) else {
            return AsyncThrowingStream { $0.finish(throwing: URLError(.badURL)) }
        }
        
        let webSocket = session.webSocketTask(with: url)
        self.webSocket = webSocket
        webSocket.resume()
        
        return AsyncThrowingStream { continuation in
            func receiveMessage() {
                webSocket.receive { [weak self] result in
                    switch result {
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            if let data = text.data(using: .utf8) {
                                do {
                                    let decoder = JSONDecoder()
                                    let dto = try decoder.decode([BinanceKlineDTO].self, from: data)
                                    continuation.yield(dto.map{$0.toDomain() ?? Candle(openTimeMs: 0, open: 0, high: 0, low: 0, close: 0, volume: 0)})
                                } catch {
                                    // 디코딩 에러 처리
                                }
                            }
                        default:
                            break
                        }
                        receiveMessage()
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                }
            }
            
            receiveMessage()
            
            continuation.onTermination = { [weak self] _ in
                self?.disconnect()
            }
        }
    }
    
    public func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
    }
}
```

### `Targets/Domain/Sources/Repositories/BinanceApiRepository.swift`

`OHLCV`를 `Candle`로 변경합니다.

```swift
//
//  BinanceApiRepository.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity

public protocol BinanceApiRepository {
    func fetchKlines(symbol: String, interval: String, limit: Int) async throws -> [Candle]
}
```
