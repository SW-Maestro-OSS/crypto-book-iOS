//
//  SplashFeature.swift
//  CryptoBookApp
//
//  Created by 김정원 on 12/11/25.
//  Copyright © 2025 io.tuist. All rights reserved.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        // 데이터 로딩, 타이머 완료 여부를 추적
        var isDataLoaded = false
        var isTimerFinished = false
        
        // 에러 메시지 추가
        var errorMessage: String?
        
        // 두 조건이 모두 충족되었는지 확인
        var isReadyToDismiss: Bool {
            isDataLoaded && isTimerFinished
        }
    }
    
    // MARK: - Action
    enum Action {
        case onAppear
        case timerFinished
        case dataLoaded(TaskResult<Bool>) // 실제로는 Bool 대신 로드된 데이터 모델이 들어갑니다.
        case delegate(DelegateAction)
        
        enum DelegateAction {
            case didFinishLoading
        }
    }
    
    // MARK: - Dependencies
    // 비동기 작업(타이머)을 위해 Clock 의존성 추가
    @Dependency(\.continuousClock) var clock
    // TODO: 여기에 데이터 로딩을 위한 API 클라이언트 의존성을 추가
    
    // MARK: - Reducer
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    // 1. 데이터 로딩 Effect
                    .run { send in
                        do {
                            // TODO: 여기서 apiClient를 사용하여 실제 데이터를 로드
                            try await self.clock.sleep(for: .seconds(1))
                            await send(.dataLoaded(.success(true)))
                        } catch {
                            await send(.dataLoaded(.failure(error)))
                        }
                    },
                    
                    // 2. 타이머 Effect
                    .run { send in
                        try await self.clock.sleep(for: .seconds(2))
                        await send(.timerFinished)
                    }
                )
                
            case .timerFinished:
                state.isTimerFinished = true
                // 타이머가 끝나고, 데이터 로딩도 끝나있다면 delegate 액션 전송
                if state.isReadyToDismiss {
                    return .send(.delegate(.didFinishLoading))
                }
                return .none
                
            case let .dataLoaded(result):
                switch result {
                case .success:
                    state.isDataLoaded = true
                    state.errorMessage = nil
                    // 데이터 로딩이 끝나고, 타이머도 끝나있다면 delegate 액션 전송
                    if state.isReadyToDismiss {
                        return .send(.delegate(.didFinishLoading))
                    }
                    return .none

                case let .failure(error):
                    state.isDataLoaded = false
                    state.errorMessage = error.localizedDescription
                    // 에러가 발생하면 스플래시는 유지되고, 부모가 errorMessage를 기반으로
                    // 에러 UI를 보여주도록 위임할 수 있음.
                    return .none
                }
                
            case .delegate:
                // Delegate 액션은 부모가 처리하므로 여기서 할 일은 없음
                return .none
            }
        }
    }
}
