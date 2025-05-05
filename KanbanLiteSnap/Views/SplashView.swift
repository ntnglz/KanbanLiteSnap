import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var currentQuote = ""
    @State private var opacity = 0.0
    
    let motivationalQuotes = [
        "Organize your ideas, achieve your goals",
        "Every task completed is a step forward",
        "Focus on what matters most",
        "Turn your ideas into achievements",
        "Simple, powerful, effective",
        "Your productivity companion",
        "Where ideas become reality",
        "Stay organized, stay productive"
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