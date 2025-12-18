//
//  NewsItem.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation

public struct NewsItem: Equatable, Identifiable {
    public var id: String { originalURL.absoluteString }

    public let title: String
    public let date: Date
    public let originalURL: URL

    public init(title: String, date: Date, originalURL: URL) {
        self.title = title
        self.date = date
        self.originalURL = originalURL
    }
}
