//
//  InitialDataRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import Domain

public final class InitialDataRepositoryImpl: InitialDataRepository {

    public func fetchInitialData() async throws -> CoinData {
        //let dto = try await api.fetchInitialData()  // 네트워크
        return CoinData(name: "dummy")            // DTO → Domain 변환
    }
}
