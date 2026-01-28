import Foundation

public enum PlistKeys {
    static public var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("API_KEY not found in Info.plist. Check your Secrets.xcconfig and project settings.")
        }
        return key
    }

    static public var cryptopanicApiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "CRYPTOPANIC_API_KEY") as? String
    }

    static public var geminiApiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String
    }
}
