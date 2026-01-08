import Foundation
import Infra

enum CryptopanicError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiKeyMissing
}

public final class CryptopanicService {
    private let baseURL = "https://cryptopanic.com/api/developer/v2/posts/"

    public init() {}

    public func fetchNews(currency: String) async throws -> CryptopanicResponseDTO {
        print("[CryptopanicService] fetchNews called for: \(currency)")

        guard let apiKey = PlistKeys.cryptopanicApiKey else {
            print("[CryptopanicService] API key missing!")
            throw CryptopanicError.apiKeyMissing
        }
        print("[CryptopanicService] API key found: \(apiKey.prefix(8))...")

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "auth_token", value: apiKey),
            URLQueryItem(name: "currencies", value: currency),
            URLQueryItem(name: "public", value: "true")
        ]

        guard let url = components?.url else {
            print("[CryptopanicService] Invalid URL!")
            throw CryptopanicError.invalidURL
        }
        print("[CryptopanicService] Request URL: \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            print("[CryptopanicService] Response received, data size: \(data.count) bytes")
            if let httpResponse = response as? HTTPURLResponse {
                print("[CryptopanicService] HTTP status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let body = String(data: data, encoding: .utf8) ?? "Unable to decode"
                    print("[CryptopanicService] Error response body: \(body.prefix(500))")
                }
            }

            let decoder = JSONDecoder()
            let dto = try decoder.decode(CryptopanicResponseDTO.self, from: data)
            print("[CryptopanicService] Decoded \(dto.results.count) results")
            return dto
        } catch let error as DecodingError {
            print("[CryptopanicService] Decoding error: \(error)")
            throw CryptopanicError.decodingError(error)
        } catch {
            print("[CryptopanicService] Network error: \(error)")
            throw CryptopanicError.networkError(error)
        }
    }
}