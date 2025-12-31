import ComposableArchitecture
import Factory

struct ExchangeRateClient {
    var fetchUSDtoKRW: @Sendable () async throws -> Double
}

extension ExchangeRateClient: DependencyKey {
    static let liveValue: Self = {
        let client: ExchangeRateClient = Container.shared.exchangeRateClient()
        return Self(
            fetchUSDtoKRW: client.fetchUSDtoKRW
        )
    }()
}

extension DependencyValues {
    var exchangeRateClient: ExchangeRateClient {
        get { self[ExchangeRateClient.self] }
        set { self[ExchangeRateClient.self] = newValue }
    }
}
