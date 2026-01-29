//
//  APIEndpoint.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

// MARK: - Protocol

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public protocol APIEndpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
}

extension APIEndpoint {
    var headers: [String: String]? { ["Content-Type": "application/json"] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }

    public func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL, userInfo: ["description": "Invalid base URL: \(baseURL)"])
        }
        components.path = path
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw URLError(.badURL, userInfo: ["description": "Failed to construct URL from components"])
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
        }
        return request
    }

    public func asWebSocketURL() throws -> URL {
        guard var components = URLComponents(string: baseURL) else {
            throw URLError(.badURL, userInfo: ["description": "Invalid WebSocket base URL: \(baseURL)"])
        }
        if !path.isEmpty {
            components.path += path
        }
        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw URLError(.badURL, userInfo: ["description": "Failed to construct WebSocket URL from components"])
        }
        return url
    }
}
