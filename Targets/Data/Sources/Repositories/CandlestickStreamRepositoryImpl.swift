//
//  KlineStreamRepositoryImpl.swift
//  Data
//
//  Created by 김정원 on 12/19/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//
//
import Foundation
import Domain
import Entity

public final class KlineStreamRepositoryImpl: KlineStreamRepository {
    private let remoteDataSource: KlineStreamDataSource

    public init(remoteDataSource: KlineStreamDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    public func kLineStream(symbol: String, interval: String) -> AsyncThrowingStream<Candle, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                var retryCount = 0
                let maxRetry = 3
                
                // 재연결을 위한 루프
                while !Task.isCancelled {
                    do {
                        // 1. 데이터 소스로부터 DTO 스트림 획득
                        let dtoStream = remoteDataSource.fetchKlineStream(symbol: symbol, interval: interval)
                        
                        for try await dtos in dtoStream {
                            // 성공적으로 데이터를 받으면 재시도 카운트 초기화
                            retryCount = 0
                            
                            // 2. DTO -> Domain 변환 (Repo의 핵심 역할)
                            do {
                                let data = try dtos.toDomain()
                                continuation.yield(data)
                            } catch {
                                print("데이터 변환 실패 : \(error)")
                                // TODO: - Data Error -> to Domain 해야함
                                continuation.finish(throwing: error)
                            }
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
                            try? await Task.sleep(nanoseconds: delay)
                            continue // 다시 while 루프 상단으로 가서 fetchTickerStream 호출
                        } else {
                            // TODO: - Data Error -> to Domain 해야함
                            continuation.finish(throwing: error)
                            break
                        }
                    }
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
