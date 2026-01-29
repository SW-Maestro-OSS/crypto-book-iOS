//
//  GeminiEndpoint.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

enum GeminiEndpoint {
    case generateContent(prompt: String)
}

extension GeminiEndpoint: APIEndpoint {
    var baseURL: String { "https://generativelanguage.googleapis.com" }
    var path: String { "/v1beta/models/gemini-2.5-flash:generateContent" }
    var method: HTTPMethod { .post }

    var queryItems: [URLQueryItem]? {
        guard let apiKey = PlistKeys.geminiApiKey else { return nil }
        return [URLQueryItem(name: "key", value: apiKey)]
    }

    var body: Data? {
        switch self {
        case .generateContent(let prompt):
            let requestBody: [String: Any] = [
                "contents": [["parts": [["text": prompt]]]],
                "generationConfig": ["temperature": 0.7, "maxOutputTokens": 1024]
            ]
            return try? JSONSerialization.data(withJSONObject: requestBody)
        }
    }
}
