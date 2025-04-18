import SwiftUI
import UserNotifications

// MARK: - OnboardingView5
struct OnboardingView5: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Image with Gradient
                ZStack(alignment: .bottom) {
                    Image("tooler") // Ensure "tooler" exists in your assets.
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height * 0.6)
                        .clipped()
                    
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                }
                
                // Title and Subtitle Text
                VStack(spacing: 8) {
                    Text("Start to continue\nwith full access")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Start using the full app functionality with a risk-free 3-days free trial, then for $7.99 per week")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 20)
                    
                    Text("or proceed with a limited version")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 20)
                
                Spacer(minLength: 0)
                
                // Continue Button
                ContinueButton(title: "Start to Continue") {
                    print("Start to Continue tapped")
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    // Add any additional action logic here.
                }
                .padding(.bottom, 40)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
}

struct OnboardingView5_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView5()
    }
}
