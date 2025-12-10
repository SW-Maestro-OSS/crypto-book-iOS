import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    @Perception.Bindable var store: StoreOf<SplashFeature>
    
    var body: some View {
        WithPerceptionTracking {
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
                store.send(.onAppear)
            }
        }
    }
}
