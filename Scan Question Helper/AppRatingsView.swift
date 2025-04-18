import SwiftUI
import StoreKit
import UserNotifications

struct AppRatingsView: View {
    @State private var hasRated = false
    @State private var animateStars = false
    @State private var hasRequestedNotifications = false
    @State private var navigateToTabBar = false // For navigation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            ZStack {
                // Base Background
                Color.black
                    .ignoresSafeArea()
                
                // Gradient Circle in the background
                GeometryReader { geometry in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.purple.opacity(0.6),
                                    Color.purple.opacity(0.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: geometry.size.width * 1.5,
                               height: geometry.size.width * 1.5)
                        .position(x: geometry.size.width, y: geometry.size.height / 2)
                        .blur(radius: 50)
                }
                .ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 20) // Optional top spacing
                    
                    // Ratings Animation (Stars)
                    HStack(spacing: 16) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                                .scaleEffect(animateStars ? 1 : 0.5)
                                .opacity(animateStars ? 1 : 0)
                                .animation(
                                    .spring(response: 0.6, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.2),
                                    value: animateStars
                                )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .padding(.vertical, 5)
                    
                    Spacer(minLength: 11)
                    
                    // Testimonials
                    VStack(spacing: 16) {
                        testimonialView(
                            text: "“I was genuinely impressed by how intuitive and helpful this app is for tackling homework. It makes problem-solving feel effortless and even enjoyable. Whether you're stuck on a tough question or just need quick explanations, it delivers reliable answers every time. A must-have for students!”",
                            author: "Perfect"
                        )
                    }
                    .padding(.horizontal)
                    
                    // Title Section (Centered)
                    VStack(alignment: .center, spacing: 8) {
                        Text("Help Us Grow")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Built to Help You")
                            .foregroundColor(.white)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                    Spacer() // Pushes the continue button to the bottom.
                    
                    // Continue Button (using your provided ContinueButton)
                    ContinueButton(action: {
                        if !hasRated {
                            requestReview()
                            hasRated = true
                        } else {
                            navigateToTabBar = true
                        }
                    })
                }
            }
            // Navigation Destination remains unchanged.
            .navigationDestination(isPresented: $navigateToTabBar) {
                OnboardingView4().navigationBarBackButtonHidden(true)
            }
            .onAppear {
                // Reset states and start stars animation
                hasRated = false
                animateStars = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        animateStars = true
                    }
                }
                if !hasRequestedNotifications {
                    hasRequestedNotifications = true
                    if UserDefaults.standard.bool(forKey: "wantsNotifications") {
                        requestNotificationPermission()
                    }
                }
            }
        }
    }
    
    // Testimonial View
    private func testimonialView(text: String, author: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(author)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 6) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Text(text)
                .font(.body)
                .italic()
                .multilineTextAlignment(.leading)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 1)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private func requestReview() {
        if #available(iOS 14.0, *) {
            SKStoreReviewController.requestReview()
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error requesting notifications: \(error.localizedDescription)")
                }
                UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
            }
        }
    }
}

struct AppRatingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppRatingsView()
    }
}
