import SwiftUI
// MARK: - StartPageView
struct StartPageView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Image with Gradient
                ZStack(alignment: .bottom) {
                    Image("woman") // Ensure "woman" exists in your asset catalog.
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
                    Text("Your AI-powered assistant\nfor every need")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Leverage AI to simplify and speed up homework. Get dependable support in all your subjects!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                
                // Spacer pushes the button toward the bottom if needed.
                Spacer(minLength: 0)
                
                // Continue Button (standardized)
                ContinueNavigationButton(destination: UnifiedOnboardingView().navigationBarBackButtonHidden(true))
                    .simultaneousGesture(TapGesture().onEnded {
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                            if let error = error {
                                print("Notification permission error: \(error.localizedDescription)")
                            } else {
                                print(granted ? "Notifications permission granted." : "Notifications permission denied.")
                            }
                        }
                    })
                    .padding(.bottom, 40) // Adds extra space at the bottom if needed.
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
        }
    }
}
