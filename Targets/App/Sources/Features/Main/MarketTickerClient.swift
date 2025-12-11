//
//  MarketTickerClient.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Domain

/// TCA에서 사용하는 마켓 티커 스트림 클라이언트
struct MarketTickerClient {
    /// 실시간 마켓 티커 스트림
    var stream: () -> AsyncThrowingStream<[MarketTicker], Error>
}

// MARK: - DependencyKey 등록

extension MarketTickerClient: DependencyKey {
    static let liveValue: Self = {
        // 실제 WebSocket 서비스를 조립
        let service = BinanceAllMarketTickersWebSocketService()

        return Self(
            stream: {
                service.connect()
            }
        )
    }()
}

// MARK: - DependencyValues 확장

extension DependencyValues {
    var marketTicker: MarketTickerClient {
        get { self[MarketTickerClient.self] }
        set { self[MarketTickerClient.self] = newValue }
    }
}
