//
//  MarketTickerRemoteDataSource.swift
//  Data
//

import Entity

protocol MarketTickerRemoteDataSource {
    func connect() -> AsyncThrowingStream<[MarketTicker], Error>
    func disconnect()
}
