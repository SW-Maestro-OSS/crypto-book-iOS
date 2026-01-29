import ComposableArchitecture
import Data
import Entity
import Foundation

struct AIInsightResult: Equatable {
    let buyPercent: Int
    let sellPercent: Int
    let summary: String
    let bullets: [String]
}

@DependencyClient
struct AIInsightClient {
    var generateInsight: @Sendable (String, [Candle], [NewsArticle]) async throws -> AIInsightResult
}

extension AIInsightClient: DependencyKey {
    static let liveValue: Self = {
        let service = GeminiService()

        return Self(
            generateInsight: { symbol, candles, news in
                let prompt = AIInsightPromptBuilder.build(symbol: symbol, candles: candles, news: news)
                let response = try await service.generateInsight(prompt: prompt)
                return AIInsightResponseParser.parse(response)
            }
        )
    }()

    static let testValue = Self(
        generateInsight: { _, _, _ in
            AIInsightResult(
                buyPercent: 60,
                sellPercent: 40,
                summary: "Test insight.",
                bullets: ["Bullet 1", "Bullet 2"]
            )
        }
    )
}

extension DependencyValues {
    var aiInsightClient: AIInsightClient {
        get { self[AIInsightClient.self] }
        set { self[AIInsightClient.self] = newValue }
    }
}

// MARK: - Prompt Builder

private enum AIInsightPromptBuilder {
    static func build(symbol: String, candles: [Candle], news: [NewsArticle]) -> String {
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
            newsHeadlines = news.map { "• \($0.title)" }.joined(separator: "\n")
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
}

// MARK: - Response Parser

private enum AIInsightResponseParser {
    static func parse(_ response: String) -> AIInsightResult {
        var buyPercent = 50
        var sellPercent = 50
        var summary = "분석을 완료했습니다."
        var bullets: [String] = []

        for line in response.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("BUY_PERCENT:") {
                let value = trimmed.replacingOccurrences(of: "BUY_PERCENT:", with: "").trimmingCharacters(in: .whitespaces)
                buyPercent = Int(value) ?? 50
            } else if trimmed.hasPrefix("SELL_PERCENT:") {
                let value = trimmed.replacingOccurrences(of: "SELL_PERCENT:", with: "").trimmingCharacters(in: .whitespaces)
                sellPercent = Int(value) ?? 50
            } else if trimmed.hasPrefix("SUMMARY:") {
                summary = trimmed.replacingOccurrences(of: "SUMMARY:", with: "").trimmingCharacters(in: .whitespaces)
            } else if trimmed.hasPrefix("BULLET1:") || trimmed.hasPrefix("BULLET2:") || trimmed.hasPrefix("BULLET3:") {
                let bullet = trimmed.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                if !bullet.isEmpty { bullets.append(bullet) }
            }
        }

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
}
