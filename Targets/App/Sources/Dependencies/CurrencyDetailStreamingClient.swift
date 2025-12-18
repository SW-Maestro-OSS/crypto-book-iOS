//
//  CurrencyDetailStreamingClient.swift
//  Data
//
//  Created by 김정원 on 12/18/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import ComposableArchitecture
import Domain

struct CurrencyDetailStreamingClient {
  var connect: @Sendable (String) -> AsyncThrowingStream<CurrencyDetailTick, Error>
  var disconnect: @Sendable () -> Void
}
