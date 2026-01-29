//
//  BinanceEndPoint.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

enum BinanceEndpoint {
    // REST
    case klines(symbol: String, interval: String, limit: Int)
    // WebSocket
    case allMarketTickers
    case candlestick(symbol: String, interval: String)
    case currencyDetail(symbol: String)
}

extension BinanceEndpoint: APIEndpoint {
    var baseURL: String {
        switch self {
        case .klines:
            return "https://api.binance.com"
        case .allMarketTickers:
            return "wss://fstream.binance.com"
        case .candlestick, .currencyDetail:
            return "wss://stream.binance.com:9443"
        }
    }

    var path: String {
        switch self {
        case .klines:
            return "/api/v3/klines"
        case .allMarketTickers:
            return "/ws/!ticker@arr"
        case .candlestick(let symbol, let interval):
            return "/ws/\(symbol.lowercased())@kline_\(interval)"
        case .currencyDetail:
            return "/stream"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .klines(let symbol, let interval, let limit):
            return [
                URLQueryItem(name: "symbol", value: symbol.uppercased()),
                URLQueryItem(name: "interval", value: interval),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        case .currencyDetail(let symbol):
            let s = symbol.lowercased()
            return [URLQueryItem(name: "streams", value: "\(s)@bookTicker/\(s)@ticker")]
        default:
            return nil
        }
    }
}
