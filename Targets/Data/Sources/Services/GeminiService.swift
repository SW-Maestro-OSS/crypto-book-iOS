import Foundation
import Infra

public enum GeminiError: Error {
    case apiKeyMissing
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiError(String)
}

public struct GeminiResponse: Decodable {
    public let candidates: [Candidate]?
    public let error: GeminiAPIError?

    public struct Candidate: Decodable {
        public let content: Content
    }

    public struct Content: Decodable {
        public let parts: [Part]
    }

    public struct Part: Decodable {
        public let text: String
    }

    public struct GeminiAPIError: Decodable {
        public let message: String
    }
}

public final class GeminiService {
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

    public init() {}

    public func generateInsight(prompt: String) async throws -> String {
        guard let apiKey = PlistKeys.geminiApiKey else {
            throw GeminiError.apiKeyMissing
        }

        guard var components = URLComponents(string: baseURL) else {
            throw GeminiError.invalidURL
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else {
            throw GeminiError.invalidURL
        }

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "maxOutputTokens": 1024
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(GeminiResponse.self, from: data)

            if let error = response.error {
                throw GeminiError.apiError(error.message)
            }

            guard let text = response.candidates?.first?.content.parts.first?.text else {
                throw GeminiError.apiError("No response generated")
            }

            return text
        } catch let error as GeminiError {
            throw error
        } catch let error as DecodingError {
            throw GeminiError.decodingError(error)
        } catch {
            throw GeminiError.networkError(error)
        }
    }
}
