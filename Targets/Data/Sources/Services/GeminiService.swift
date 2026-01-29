import Foundation

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
    public init() {}

    public func generateInsight(prompt: String) async throws -> String {
        guard PlistKeys.geminiApiKey != nil else {
            throw GeminiError.apiKeyMissing
        }

        let endpoint = GeminiEndpoint.generateContent(prompt: prompt)
        
        do {
            let request = try endpoint.asURLRequest()
            
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
