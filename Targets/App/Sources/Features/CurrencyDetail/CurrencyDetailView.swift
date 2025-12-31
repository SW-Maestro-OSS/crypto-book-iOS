import SwiftUI
import ComposableArchitecture
import Entity
import Infra // CachedAsyncImage 사용을 위함

struct CurrencyDetailView: View {
    @Perception.Bindable var store: StoreOf<CurrencyDetailFeature>
    @Environment(\.openURL) var openURL // 뉴스 URL을 열기 위함

    var body: some View {
        WithPerceptionTracking {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Header Section: 실시간 가격 및 등락률
                    headerSection
                    
                    Divider()

                    // 2. Chart Section: 7일 캔들 차트 (Placeholder 형태)
                    chartSection
                    
                    Divider()

                    // 3. AI Insight Section: 매수/매도 심리 및 분석 요약
                    aiInsightSection
                    
                    Divider()

                    // 4. News Section: 관련 종목 뉴스 및 아티클
                   // newsSection
                }
                .padding()
            }
            .navigationTitle(store.symbol)
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                // 당겨서 새로고침
                await store.send(.refreshPulled).finish()
            }
            .onAppear { store.send(.onAppear) }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .bottom) {
                if let midPrice = store.midPrice {
                    Text(String(format: "%.4f", midPrice))
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                } else {
                    Text("---")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Text("USDT")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }

            if let change = store.changePercent24h {
                HStack {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%.2f%%", change))
                    Text("지난 24시간")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline.bold())
                .foregroundStyle(change >= 0 ? .green : .red) // 양전 초록, 음전 빨강
            }
            
            if let lastUpdated = store.lastUpdated {
                Text("최근 업데이트: \(lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7D Chart (1D Interval)")
                .font(.headline)
            
            if store.chartLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else if store.candles.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(Text("차트 데이터를 불러올 수 없습니다.").font(.caption))
            } else {
                // 실제 차트 라이브러리 연동 전까지는 캔들 데이터를 이용한 간단한 시각화 영역
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                    .frame(height: 150)
                    .overlay(
                        Text("\(store.candles.count)개의 캔들 데이터 로드됨")
                            .font(.caption)
                    )
            }
        }
    }

    private var aiInsightSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insight")
                .font(.headline)
            
            if let insight = store.insight {
                VStack(spacing: 12) {
                    // 매수/매도 게이지 바
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.red)
                            .frame(width: CGFloat(insight.sellPercent) * 2.5, height: 20)
                            .overlay(Text("매도 \(insight.sellPercent)").font(.caption2).bold().white(), alignment: .leading)
                        
                        Rectangle()
                            .fill(.green)
                            .frame(width: CGFloat(insight.buyPercent) * 2.5, height: 20)
                            .overlay(Text("매수 \(insight.buyPercent)").font(.caption2).bold().white(), alignment: .trailing)
                    }
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity)
                    
                    // 인사이트 요약 불렛 포인트
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(insight.bullets, id: \.self) { bullet in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                Text(bullet)
                                    .font(.subheadline)
                                    .lineLimit(nil)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            } else if store.insightLoading {
                ProgressView("분석 중...")
                    .frame(maxWidth: .infinity)
            }
        }
    }

}

// 텍스트 색상 편의를 위한 확장
extension View {
    func white() -> some View { self.foregroundStyle(.white) }
}
