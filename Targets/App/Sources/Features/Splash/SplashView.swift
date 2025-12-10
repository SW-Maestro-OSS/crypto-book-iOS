import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
            
            Text("CryptoBook")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}
