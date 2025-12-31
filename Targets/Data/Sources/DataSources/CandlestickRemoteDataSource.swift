import Entity
import Foundation

/// 실시간 캔들 데이터 스트리밍을 위한 데이터 소스 프로토콜입니다.
protocol CandlestickRemoteDataSource {
    /// 지정된 심볼과 주기에 대한 캔들 데이터 스트림에 연결합니다.
    /// - Parameters:
    ///   - symbol: 암호화폐 심볼 (e.g., "BTCUSDT")
    ///   - interval: 캔들 주기 (e.g., "1m", "1d")
    /// - Returns: `Candle`을 방출하는 비동기 스트림
    func connect(symbol: String, interval: String) -> AsyncThrowingStream<Candle, Error>

    /// 웹소켓 연결을 해제합니다.
    func disconnect()
}
