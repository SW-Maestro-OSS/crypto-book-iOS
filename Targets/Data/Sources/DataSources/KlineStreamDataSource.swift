//
//  CandlestickStreamDataSource.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

/// 특정 암호화폐의 봉을 그리기 위한 스트림
public protocol KlineStreamDataSource {
    func fetchKlineStream(symbol: String, interval: String) -> AsyncThrowingStream<BinanceKlineDTO, Error>
}
