//
//  InitialDataRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Entity
import Domain

public final class MarketTickerStreamRepositoryImpl: MarketTickerStreamRepository {
    private let remoteDataSource: MarketTickerRemoteDataSource
    
    public init(remoteDataSource: MarketTickerRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    public func tickerStream() -> AsyncThrowingStream<[MarketTicker], Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                var retryCount = 0
                let maxRetry = 3
                
                // 재연결을 위한 루프
                while !Task.isCancelled {
                    do {
                        // 1. 데이터 소스로부터 DTO 스트림 획득
                        let dtoStream = remoteDataSource.fetchTickerStream()
                        
                        for try await dtos in dtoStream {
                            // 성공적으로 데이터를 받으면 재시도 카운트 초기화
                            retryCount = 0
                            
                            // 2. DTO -> Domain 변환 (Repo의 핵심 역할)
                            let tickers = dtos.map { $0.toDomain() }
                            continuation.yield(tickers)
                        }
                        
                        // 스트림이 정상 종료된 경우
                        continuation.finish()
                        break
                        
                    } catch {
                        // 3. Retry 정책 적용 (Exponential Backoff)
                        if retryCount < maxRetry {
                            retryCount += 1
                            // 재시도 횟수에 따라 대기 시간 증가 (2, 4, 8, 16... 초)
                            let delay = UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000)
                            print("연결 실패, \(retryCount)번째 재시도 중... (\(delay/1_000_000_000)초 대기)")
                            
                            try? await Task.sleep(nanoseconds: delay)
                            continue // 다시 while 루프 상단으로 가서 fetchTickerStream 호출
                        } else {
                            // 최대 재시도 횟수 초과 시 에러 전달 및 종료
                            continuation.finish(throwing: error)
                            break
                        }
                    }
                }
            }
            
            // 4. 외부(UseCase/ViewModel)에서 구독 취소 시 내부 Task도 취소
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
