import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var currentQuote = ""
    @State private var opacity = 0.0
    
    let motivationalQuotes = [
        "splash.motivational.1".localized,
        "splash.motivational.2".localized,
        "splash.motivational.3".localized,
        "splash.motivational.4".localized,
        "splash.motivational.5".localized,
        "splash.motivational.6".localized,
        "splash.motivational.7".localized,
        "splash.motivational.8".localized
    ]
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack(spacing: 32) {
                Spacer()
                
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
                    .opacity(opacity)
                
                Text(currentQuote)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .opacity(opacity)
                
                Spacer()
            }
            .onAppear {
                currentQuote = motivationalQuotes.randomElement()!
                withAnimation(.easeIn(duration: 1.5)) {
                    opacity = 1.0
                }
                
                // After 3 seconds, transition to main content
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
} 