import SwiftUI

struct SplashScreenView: View {
    // Controls when to switch to the StartPageView.
    @State private var isActive = false
    // Toggles the glow effect.
    @State private var glow = false

    var body: some View {
        // Conditional view: if isActive is true, show StartPageView.
        if isActive {
            StartPageView()
        } else {
            ZStack {
                // Black background fills the entire screen.
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                // The image with a purple glow effect.
                Image("NoBackLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    // Apply a purple shadow that changes its blur radius to create a "glow".
                    .shadow(color: .purple, radius: glow ? 20 : 0)
            }
            .onAppear {
                // Start the glow animation immediately.
                withAnimation(.easeInOut(duration: 1)) {
                    glow = true
                }
                // After one second, switch to the StartPageView.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        SplashScreenView()
    }
}

#Preview {
    ContentView()
}
