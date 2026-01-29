//
//  MarketTickerRemoteDataSource.swift
//  Data
//
import Foundation
/// 모든 암호화폐의 시장가 정보를 실시간으로 받아오는 데이터 소스
public protocol MarketTickerStreamDataSource {
    func fetchTickerStream() -> AsyncThrowingStream<[MarketTickerDTO], Error>
}
