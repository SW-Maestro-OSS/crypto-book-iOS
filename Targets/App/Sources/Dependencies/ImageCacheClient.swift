//
//  Untitled.swift
//  CryptoBook
//
//  Created by 김정원 on 12/15/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import ComposableArchitecture
import UIKit
import Infra

public struct ImageCacheClient {
    public var prefetch: ([URL]) async -> Void
    public var image: (URL) async -> UIImage?
}

extension ImageCacheClient: DependencyKey {
    public static let liveValue: Self = {
        let cache = ImageCache()
        return Self(
            prefetch: { urls in await cache.prefetch(urls: urls) },
            image: { url in await cache.image(for: url) }
        )
    }()
}

extension DependencyValues {
    public var imageCache: ImageCacheClient {
        get { self[ImageCacheClient.self] }
        set { self[ImageCacheClient.self] = newValue }
    }
}
