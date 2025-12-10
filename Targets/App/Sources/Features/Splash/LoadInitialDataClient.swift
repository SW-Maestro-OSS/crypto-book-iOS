//
//  LoadInitialDataClient.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Domain

struct LoadInitialDataClient {
    /// 초기 데이터를 로드하는 비동기 작업.
    var call: () async throws -> Bool
}

// MARK: - DependencyKey 등록

extension LoadInitialDataClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            call: {
                // TODO: Repository 호출로 변경 예정
                return true
            }
        )
    }()
}

extension DependencyValues {
    /// SplashFeature 등에서 사용할 의존성 접근자.
    var loadInitialData: LoadInitialDataClient {
        get { self[LoadInitialDataClient.self] }
        set { self[LoadInitialDataClient.self] = newValue }
    }
}
