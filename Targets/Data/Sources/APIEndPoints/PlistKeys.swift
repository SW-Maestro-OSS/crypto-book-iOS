//
//  PlistKeys.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

enum PlistKeys {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist. Check your Secrets.xcconfig and project settings.")
        }
        return key
    }

    static var cryptopanicApiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "CRYPTOPANIC_API_KEY") as? String
    }

    static var geminiApiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
    }
}
