//
//  CryptopanicEndpoint.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

enum CryptopanicEndpoint {
    case posts(currency: String)
}

extension CryptopanicEndpoint: APIEndpoint {
    var baseURL: String { "https://cryptopanic.com" }
    var path: String { "/api/developer/v2/posts/" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        guard let apiKey = PlistKeys.cryptopanicApiKey else { return nil }
        switch self {
        case .posts(let currency):
            return [
                URLQueryItem(name: "auth_token", value: apiKey),
                URLQueryItem(name: "currencies", value: currency),
                URLQueryItem(name: "public", value: "true")
            ]
        }
    }
}
