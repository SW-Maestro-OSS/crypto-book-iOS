//
//  CurrencyDetailRemoteDataSource.swift
//  Data
//

import Domain

protocol CurrencyDetailRemoteDataSource: Sendable {
    func connect(symbol: String) -> AsyncThrowingStream<CurrencyDetailTick, Error>
    func disconnect()
}
