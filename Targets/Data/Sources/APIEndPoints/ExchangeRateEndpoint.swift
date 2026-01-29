//
//  ExchangeRateEndpoint.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

enum ExchangeRateEndpoint {
    case fetchRates
}

extension ExchangeRateEndpoint: APIEndpoint {
    var baseURL: String { "https://www.koreaexim.go.kr" }
    var path: String { "/site/program/financial/exchangeJSON" }
    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        let apiKey = PlistKeys.apiKey
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return [
            URLQueryItem(name: "authkey", value: apiKey),
            URLQueryItem(name: "searchdate", value: formatter.string(from: Date())),
            URLQueryItem(name: "data", value: "AP01")
        ]
    }
}
