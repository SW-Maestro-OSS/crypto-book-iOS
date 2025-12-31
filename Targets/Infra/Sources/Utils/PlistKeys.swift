import Foundation

public enum PlistKeys {
    static public var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            // This will cause a fatal error if the key is not set,
            // which is desirable to catch configuration errors early.
            fatalError("API_KEY not found in Info.plist. Check your Secrets.xcconfig and project settings.")
        }
        // It's not good practice to return an empty string. If the key is missing, we should fail loudly.
        // However, to prevent crashing in release builds if something goes wrong,
        // we might return an empty string and let the API call fail.
        // For this project, we'll stick with fatalError to enforce correct setup.
        return key
    }
}
