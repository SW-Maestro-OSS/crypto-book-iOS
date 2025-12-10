import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashFeature>
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
            
            Text("CryptoBook")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 에러가 있을 경우 표시
            if let errorMessage = store.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
        }
        .onAppear {
            // 스플래시가 나타날 때 TCA Feature에 onAppear 액션 전달
            store.send(.onAppear)
        }
    }
}
