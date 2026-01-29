//
//  CandlestickStreamRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Entity

public protocol CandleStickStreamRepository {
    func kLineStream(symbol: String, interval: String) -> AsyncThrowingStream<Candle, Error>
}
