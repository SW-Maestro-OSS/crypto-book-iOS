# 데이터 소스 프로토콜 리팩토링

`Candlestick` 데이터를 스트리밍하는 서비스에 대한 명확한 역할을 정의하기 위해 새로운 프로토콜 `CandlestickRemoteDataSource`를 생성하고, 관련 서비스를 업데이트합니다.

## 신규 파일 생성

### `Targets/Data/Sources/DataSources/CandlestickRemoteDataSource.swift`

`[Candle]` 타입의 비동기 스트림을 반환하는 `connect` 메서드를 가진 프로토콜을 새로 정의합니다.

```swift
//
//  CandlestickRemoteDataSource.swift
//  Data
//
//  Created by 김정원 on 12/31/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Entity
import Foundation

/// 실시간 캔들 데이터 스트리밍을 위한 데이터 소스 프로토콜입니다.
protocol CandlestickRemoteDataSource {
    /// 지정된 심볼과 주기에 대한 캔들 데이터 스트림에 연결합니다.
    /// - Parameters:
    ///   - symbol: 암호화폐 심볼 (e.g., "BTCUSDT")
    ///   - interval: 캔들 주기 (e.g., "1m", "1d")
    /// - Returns: `[Candle]` 배열을 방출하는 비동기 스트림
    func connect(symbol: String, interval: String) -> AsyncThrowingStream<[Candle], Error>

    /// 웹소켓 연결을 해제합니다.
    func disconnect()
}
```

## 파일 내용 변경

### `Targets/Data/Sources/Services/BinanceCandlestickStreamingWebSocketService.swift`

기존 `BinanceCandlestickStreamingWebSocketService`가 새로 만든 `CandlestickRemoteDataSource` 프로토콜을 준수하도록 수정합니다.

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

/// 특정 암호화폐의 양봉 정보를 실시간으로 받아옴
final class BinanceCandlestickStreamingWebSocketService: CandlestickRemoteDataSource {
    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func connect(symbol: String, interval: String) -> AsyncThrowingStream<[Candle], Error> {
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
                                    let candles = dto.compactMap { $0.toDomain() }
                                    if !candles.isEmpty {
                                        continuation.yield(candles)
                                    }
                                } catch {
                                    // Decoding error - skip this message
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