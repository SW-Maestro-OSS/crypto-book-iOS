//
//  CandlestickStreamDataSourceImpl.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public final class KlineStreamDataSourceImpl: KlineStreamDataSource {
    
    private let wsClient: WebSocketClient
    private let decoder: JSONDecoder
    
    public init(wsClient: WebSocketClient, decoder: JSONDecoder = JSONDecoder()) {
        self.wsClient = wsClient
        self.decoder = decoder
    }
    
    public func fetchKlineStream(symbol: String, interval: String) -> AsyncThrowingStream<BinanceKlineDTO, Error> {
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    let url = try BinanceEndpoint.klineStream(symbol: symbol, interval: interval).asWebSocketURL()
                    
                    let rawStream = wsClient.connect(url: url)
                    
                    for try await data in rawStream {
                        // 3. 인프라는 데이터를 모르지만, 데이터 소스는 여기서 DTO로 변환
                        do {
                            let dtos = try decoder.decode(BinanceKlineDTO.self, from: data)
                            continuation.yield(dtos)
                        } catch {
                            print("데이터 소스 파싱 에러: \(error)")
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            
            // 4. 외부에서 스트림을 취소할 경우 인프라 연결도 끊어줌
            continuation.onTermination = { [weak self] _ in
                self?.wsClient.disconnect()
            }
        }
    }
}

