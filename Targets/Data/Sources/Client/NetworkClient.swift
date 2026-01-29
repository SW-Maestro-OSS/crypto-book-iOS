//
//  NetworkClient.swift
//  Data
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

public protocol NetworkClient {
    func request(endpoint: APIEndpoint) async throws -> Data
}
