//
//  URLSessionNetworkClient.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import Data

public final class URLSessionNetworkClient: NetworkClient {
    private let session: URLSession = .shared

    public init() {}

    public func request(endpoint: APIEndpoint) async throws -> Data {
        let request = try endpoint.asURLRequest()
        
        // URLSession은 기본적으로 (Data, URLResponse)를 반환합니다.
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }
}
