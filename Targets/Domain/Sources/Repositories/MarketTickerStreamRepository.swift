//
//  MarketTickerStreamRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//
import Entity
public protocol MarketTickerStreamRepository {
    func tickerStream() -> AsyncThrowingStream<[MarketTicker], Error>
}
