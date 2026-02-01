//
//  FetchNewsArticleUseCase.swift
//  Data
//
//  Created by 김정원 on 2/1/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation
import Entity

public final class FetchNewsArticleUseCase {
    private let repository: NewsRepository

    public init(repository: NewsRepository) {
        self.repository = repository
    }
    
    public func execute(currency: String) async throws -> [NewsArticle] {
        try await repository.fetchNews(currency: currency)
    }
}
