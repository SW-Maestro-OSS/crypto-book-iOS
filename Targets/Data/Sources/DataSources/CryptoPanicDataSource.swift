//
//  CryptoPanicDataSource.swift
//  Data
//
//  Created by 김정원 on 1/30/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public protocol CryptoPanicDataSource {
    func fetch(currency: String) async throws -> CryptoPanicResponseDTO
}
