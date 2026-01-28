import ComposableArchitecture
import Data
import Entity
import Foundation

public struct AIInsightResult: Equatable {
    public let buyPercent: Int
    public let sellPercent: Int
    public let summary: String
    public let bullets: [String]
}

@DependencyClient
public struct AIInsightClient {
    public var generateInsight: @Sendable (String, [Candle], [NewsArticle]) async throws -> AIInsightResult
}

extension AIInsightClient: DependencyKey {
    public static let liveValue: Self = {
        let service = GeminiService()

        return Self(
            generateInsight: { symbol, candles, news in
                let prompt = buildPrompt(symbol: symbol, candles: candles, news: news)
                print("[AI] Prompt:\n\(prompt)")
                let response = try await service.generateInsight(prompt: prompt)
                print("[AI] Response:\n\(response)")
                return parseResponse(response)
            }
        )
    }()

    public static let testValue = Self(
        generateInsight: { _, _, _ in
            AIInsightResult(
                buyPercent: 60,
                sellPercent: 40,
                summary: "테스트 인사이트입니다.",
                bullets: ["테스트 bullet 1", "테스트 bullet 2"]
            )
        }
    )
}

private func buildPrompt(symbol: String, candles: [Candle], news: [NewsArticle]) -> String {
    let currency = symbol.replacingOccurrences(of: "USDT", with: "")

    var chartInfo = ""
    if !candles.isEmpty {
        let firstOpen = candles.first?.open ?? 0
        let lastClose = candles.last?.close ?? 0
        let change = firstOpen > 0 ? ((lastClose - firstOpen) / firstOpen) * 100 : 0
        let trend = change >= 0 ? "상승" : "하락"
        chartInfo = "7일간 \(String(format: "%.1f", abs(change)))% \(trend)"
    }

    var newsHeadlines = ""
    if !news.isEmpty {
        let titles = news.map { "• \($0.title)" }.joined(separator: "\n")
        newsHeadlines = titles
    }

    return """
    \(currency) 뉴스:
    \(newsHeadlines.isEmpty ? "없음" : newsHeadlines)

    차트: \(chartInfo.isEmpty ? "없음" : chartInfo)

    위 정보로 시장 분석해서 아래 형식 그대로 답변해. 각 항목 반드시 채워.

    BUY_PERCENT: 60
    SELL_PERCENT: 40
    BULLET1: 첫번째 인사이트 문장
    BULLET2: 두번째 인사이트 문장
    BULLET3: 세번째 인사이트 문장

    한국어로.
    """
}

private func parseResponse(_ response: String) -> AIInsightResult {
    var buyPercent = 50
    var sellPercent = 50
    var summary = "분석을 완료했습니다."
    var bullets: [String] = []

    let lines = response.components(separatedBy: "\n")

    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)

        if trimmed.hasPrefix("BUY_PERCENT:") {
            let value = trimmed.replacingOccurrences(of: "BUY_PERCENT:", with: "").trimmingCharacters(in: .whitespaces)
            buyPercent = Int(value) ?? 50
        } else if trimmed.hasPrefix("SELL_PERCENT:") {
            let value = trimmed.replacingOccurrences(of: "SELL_PERCENT:", with: "").trimmingCharacters(in: .whitespaces)
            sellPercent = Int(value) ?? 50
        } else if trimmed.hasPrefix("SUMMARY:") {
            summary = trimmed.replacingOccurrences(of: "SUMMARY:", with: "").trimmingCharacters(in: .whitespaces)
        } else if trimmed.hasPrefix("BULLET1:") {
            let bullet = trimmed.replacingOccurrences(of: "BULLET1:", with: "").trimmingCharacters(in: .whitespaces)
            if !bullet.isEmpty { bullets.append(bullet) }
        } else if trimmed.hasPrefix("BULLET2:") {
            let bullet = trimmed.replacingOccurrences(of: "BULLET2:", with: "").trimmingCharacters(in: .whitespaces)
            if !bullet.isEmpty { bullets.append(bullet) }
        } else if trimmed.hasPrefix("BULLET3:") {
            let bullet = trimmed.replacingOccurrences(of: "BULLET3:", with: "").trimmingCharacters(in: .whitespaces)
            if !bullet.isEmpty { bullets.append(bullet) }
        }
    }

    // Ensure percentages add up to 100
    if buyPercent + sellPercent != 100 {
        sellPercent = 100 - buyPercent
    }

    if bullets.isEmpty {
        bullets = ["차트 및 뉴스 데이터를 기반으로 분석했습니다."]
    }

    return AIInsightResult(
        buyPercent: buyPercent,
        sellPercent: sellPercent,
        summary: summary,
        bullets: bullets
    )
}

extension DependencyValues {
    public var aiInsightClient: AIInsightClient {
        get { self[AIInsightClient.self] }
        set { self[AIInsightClient.self] = newValue }
    }
}
