//
//  CryptoPanicDataSourceImpl.swift
//  Data
//
//  Created by 김정원 on 1/30/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public final class CryptoPanicDataSourceImpl: CryptoPanicDataSource {

    private let networkClient: NetworkClient // 인프라 주입
    private let decoder = JSONDecoder()

    public init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    public func fetch(currency: String) async throws -> CryptoPanicResponseDTO {
        let endPoint = CryptopanicEndpoint.posts(currency: currency)
        
        let data = try await networkClient.request(endpoint: endPoint)
        
        return try decoder.decode(CryptoPanicResponseDTO.self, from: data)
    }
    
}
