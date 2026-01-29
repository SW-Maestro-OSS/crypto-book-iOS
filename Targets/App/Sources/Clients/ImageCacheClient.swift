import ComposableArchitecture
import UIKit
import Infra

struct ImageCacheClient {
    var prefetch: ([URL]) async -> Void
    var image: (URL) async -> UIImage?
}

extension ImageCacheClient: DependencyKey {
    static let liveValue: Self = {
        let cache = ImageCache()
        return Self(
            prefetch: { urls in await cache.prefetch(urls: urls) },
            image: { url in await cache.image(for: url) }
        )
    }()
}

extension DependencyValues {
    var imageCache: ImageCacheClient {
        get { self[ImageCacheClient.self] }
        set { self[ImageCacheClient.self] = newValue }
    }
}
