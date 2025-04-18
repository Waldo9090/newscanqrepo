import SwiftUI

// MARK: - OnboardingView4
struct OnboardingView4: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Image with Gradient
                ZStack(alignment: .bottom) {
                    Image("manusingphone") // Ensure this image exists in your assets.
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
                    Text("Find dependable answers")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Text("Experience the reassurance of accurate, trustworthy solutions tailored to your academic needs with our AI homework helper.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                .padding(.vertical, 20)
                
                Spacer(minLength: 0)
                
                // Continue Button
                ContinueNavigationButton(destination: TabBarView().navigationBarBackButtonHidden(true))
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
