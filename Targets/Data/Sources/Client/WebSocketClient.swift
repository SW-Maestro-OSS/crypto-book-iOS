//
//  File.swift
//  CryptoBookApp
//
//  Created by 김정원 on 1/29/26.
//  Copyright © 2026 io.tuist. All rights reserved.
//

import Foundation

/// 소켓 연결과 원시 데이터 수신만 담당하는 순수 인프라 계층
public protocol WebSocketClient {
    func connect(url: URL) -> AsyncThrowingStream<Data, Error>
    func disconnect()
}
