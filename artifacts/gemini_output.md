# 실시간 가격 DTO 파싱 오류 수정

`CurrencyDetailView` 진입 시 실시간 가격 데이터를 DTO로 변환하는 과정의 오류를 해결합니다.

**문제 원인:**
`BinanceCurrencyDetailWebSocketService`의 `parseTick` 함수가 `try?`를 사용하여 디코딩 오류를 조용히 무시하고 있었습니다. 이로 인해 바이낸스 API로부터 받은 `bookTicker` 메시지 파싱에 실패하더라도 원인을 알 수 없었고, 가격 정보가 DTO에 담겨 뷰까지 전달되지 않았습니다.

**해결책:**
`parseTick` 함수를 보다 안정적인 방식으로 재작성하여 이 문제를 해결합니다.

1.  먼저 JSON 데이터를 범용 딕셔너리로 파싱하여 `stream` 필드를 통해 데이터의 종류를 안전하게 확인합니다.
2.  `stream` 이름에 따라(`@bookTicker` 또는 `@ticker`) 해당하는 특정 DTO로만 디코딩을 시도합니다.
3.  `try?` 대신 `try`를 사용하여, 디코딩 실패 시 에러가 발생하도록 변경합니다. 이를 통해 문제가 발생했을 때 원인을 명확하게 인지할 수 있습니다.

이러한 변경으로 데이터 파싱 과정의 안정성을 확보하여, 실시간 가격이 DTO에 올바르게 담겨 화면에 표시되도록 합니다.

## 파일 내용 변경

### `Targets/Data/Sources/Services/BinanceCurrencyDetailWebSocketService.swift`

```swift
//
//  BinanceCurrencyDetailWebSocketService.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//

import Foundation
import Domain
/// 특정 암호화폐의 상세정보를 실시간으로 받아옴
final class BinanceCurrencyDetailWebSocketService: CurrencyDetailRemoteDataSource, @unchecked Sendable {

    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Connects to Binance WS for a single symbol and emits `CurrencyDetailTick`.
    func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error> {
        let lower = symbol.lowercased()

        // bookTicker (mid price) + 24hr ticker (change percent)
        let streams = "\(lower)@bookTicker/\(lower)@ticker"
        let urlString = "wss://stream.binance.com:9443/stream?streams=\(streams)"
        let url = URL(string: urlString)!

        // Cancel any existing connection (screen re-appear)
        webSocketTask?.cancel(with: .normalClosure, reason: nil)

        let task = session.webSocketTask(with: url)
        self.webSocketTask = task
        task.resume()

        return AsyncThrowingStream { [weak self] continuation in
            guard let self else {
                continuation.finish()
                return
            }

            func receiveNext() {
                task.receive { result in
                    switch result {
                    case .failure(let error):
                        continuation.finish(throwing: error)

                    case .success(let message):
                        do {
                            let data: Data
                            switch message {
                            case .data(let d): data = d
                            case .string(let s): data = Data(s.utf8)
                            @unknown default:
                                receiveNext()
                                return
                            }

                            if let tick = try self.parseTick(from: data) {
                                continuation.yield(tick)
                            }
                            receiveNext()
                        } catch {
                            // If parsing fails, terminate the stream to make the error visible.
                            continuation.finish(throwing: error)
                        }
                    }
                }
            }

            receiveNext()

            continuation.onTermination = { [weak self] _ in
                self?.webSocketTask?.cancel(with: .normalClosure, reason: nil)
                self?.webSocketTask = nil
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }
}

// MARK: - Parsing
private extension BinanceCurrencyDetailWebSocketService {

    struct StreamEnvelope<T: Decodable>: Decodable {
        let stream: String
        let data: T
    }

    struct BookTickerDTO: Decodable {
        let s: String      // symbol
        let b: String      // best bid price
        let a: String      // best ask price
    }

    struct Ticker24hDTO: Decodable {
        let s: String      // symbol
        let P: String      // price change percent
    }

    func parseTick(from data: Data) throws -> CurrencyDetailTick? {
        // First, decode into a generic dictionary to inspect the stream name safely.
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let streamName = json["stream"] as? String,
              let jsonData = json["data"] as? [String: Any] else {
            // Not the format we expect (envelope with stream/data), so ignore.
            return nil
        }

        // Re-serialize the inner 'data' object to decode it with a specific DTO.
        let innerData = try JSONSerialization.data(withJSONObject: jsonData)

        if streamName.hasSuffix("@bookTicker") {
            let ticker = try JSONDecoder().decode(BookTickerDTO.self, from: innerData)
            let bid = Double(ticker.b)
            let ask = Double(ticker.a)
            let mid = (bid != nil && ask != nil) ? ((bid! + ask!) / 2.0) : nil
            return CurrencyDetailTick(symbol: ticker.s, midPrice: mid, changePercent24h: nil)
        }

        if streamName.hasSuffix("@ticker") {
            let ticker = try JSONDecoder().decode(Ticker24hDTO.self, from: innerData)
            let change = Double(ticker.P)
            return CurrencyDetailTick(symbol: ticker.s, midPrice: nil, changePercent24h: change)
        }

        // The stream name is not one we handle.
        return nil
    }
}
```