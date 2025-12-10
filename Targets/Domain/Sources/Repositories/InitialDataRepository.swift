//
//  InitialDataRepository.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

public protocol InitialDataRepository {
    func fetchInitialData() async throws -> CoinData
}
