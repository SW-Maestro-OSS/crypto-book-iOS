import Foundation

enum CryptopanicError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case apiKeyMissing
}

public final class CryptopanicService {
    public init() {}

    public func fetchNews(currency: String) async throws -> CryptopanicResponseDTO {
        print("[CryptopanicService] fetchNews called for: \(currency)")

        // API 키 존재 여부를 먼저 확인합니다.
        guard PlistKeys.cryptopanicApiKey != nil else {
            print("[CryptopanicService] API key missing!")
            throw CryptopanicError.apiKeyMissing
        }

        let endpoint = CryptopanicEndpoint.posts(currency: currency)
        
        do {
            let request = try endpoint.asURLRequest()
            print("[CryptopanicService] Request URL: \(request.url?.absoluteString ?? "N/A")")

            let (data, response) = try await URLSession.shared.data(for: request)
            
            print("[CryptopanicService] Response received, data size: \(data.count) bytes")
            if let httpResponse = response as? HTTPURLResponse {
                print("[CryptopanicService] HTTP status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let body = String(data: data, encoding: .utf8) ?? "Unable to decode"
                    print("[CryptopanicService] Error response body: \(body.prefix(500))")
                    // Consider throwing a more specific error here based on status code
                }
            }

            let decoder = JSONDecoder()
            let dto = try decoder.decode(CryptopanicResponseDTO.self, from: data)
            print("[CryptopanicService] Decoded \(dto.results.count) results")
            return dto
        } catch let error as DecodingError {
            print("[CryptopanicService] Decoding error: \(error)")
            throw CryptopanicError.decodingError(error)
        } catch let error as URLError {
            print("[CryptopanicService] URL error: \(error)")
            throw CryptopanicError.invalidURL
        } catch {
            print("[CryptopanicService] Network error: \(error)")
            throw CryptopanicError.networkError(error)
        }
    }
}
