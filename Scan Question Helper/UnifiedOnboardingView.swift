import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let content: AnyView
}

struct UnifiedOnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    @AppStorage("isOnboardingComplete") var isOnboardingCompleteStorage: Bool = false
    @State private var animateContent = false
    
    // Define Neon Purple Color
    let neonPurple = Color(red: 0.6, green: 0.0, blue: 1.0)
    
    private let onboardingPages: [OnboardingPage] = [
        OnboardingPage(content: AnyView(FirstOnboardingPage())),
        OnboardingPage(content: AnyView(SecondOnboardingPage())),
        OnboardingPage(content: AnyView(ThirdOnboardingPage()))
    ]
    
    // Add haptic feedback generator
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Page content
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            onboardingPages[index].content
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: currentPage) { _ in
                        withAnimation {
                            animateContent.toggle()
                        }
                    }
                    
                    // Bottom controls
                    VStack(spacing: 20) {
                        PageIndicator(currentPage: currentPage, totalPages: onboardingPages.count)
                        
                        Button(action: {
                            // Add haptic feedback
                            hapticFeedback.impactOccurred()
                            
                            withAnimation(.spring()) {
                                if currentPage < onboardingPages.count - 1 {
                                    currentPage += 1
                                } else {
                                    isOnboardingComplete = true
                                    isOnboardingCompleteStorage = true
                                }
                            }
                        }) {
                            HStack {
                                Text(currentPage < onboardingPages.count - 1 ? "Continue" : "Get Started")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(neonPurple)
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 40)
                        }
                    }
                }
                
                NavigationLink(destination: TabBarView().navigationBarBackButtonHidden(true), isActive: $isOnboardingComplete) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// First Onboarding Page
struct FirstOnboardingPage: View {
    @State private var animateTitle = false
    @State private var animateCard = false
    @State private var animateSolution = false
    
    var body: some View {
        VStack(spacing: 40) {
            // Title
            Text("Smart Math Solutions")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 60)
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : 20)
            
            // Example Math Problem Card
            VStack(spacing: 20) {
                ForEach(1...3, id: \.self) { index in
                    HStack(spacing: 12) {
                        Text("\(index).")
                            .foregroundColor(.gray)
                        
                        Text(getMathProblem(index))
                            .padding(.vertical, 8)
                            .padding(.horizontal, index == 2 ? 12 : 0)
                            .background(index == 2 ? Color.purple.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                    }
                    .font(.system(size: 16))
                }
            }
            .padding(24)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            .padding(.horizontal)
            .opacity(animateCard ? 1 : 0)
            .offset(y: animateCard ? 0 : 30)
            
            // Solution Card
            HStack(spacing: 20) {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "sparkles")
                            .foregroundColor(.white)
                    )
                
                Text("x = 7/2")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(20)
            .background(Color.white.opacity(0.05))
            .cornerRadius(20)
            .padding(.horizontal)
            .opacity(animateSolution ? 1 : 0)
            .offset(y: animateSolution ? 0 : 20)
            
            Spacer()
            
            // Description
            VStack(spacing: 12) {
                Text("Scan & Solve")
                    .font(.system(size: 32, weight: .bold))
                Text("Get instant solutions")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
            .opacity(animateTitle ? 1 : 0)
        }
        .foregroundColor(.white)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                animateCard = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                animateSolution = true
            }
        }
    }
    
    private func getMathProblem(_ index: Int) -> String {
        switch index {
        case 1: return "Solve: 2x² + 5x - 12 = 0"
        case 2: return "Find x: log₂(x) + log₂(x+3) = 3"
        case 3: return "Evaluate: ∫(2x + 1)dx from 0 to 2"
        default: return ""
        }
    }
}

// Second Onboarding Page
struct SecondOnboardingPage: View {
    @State private var animateTitle = false
    @State private var animateTools = false
    
    let toolSize: CGFloat = (UIScreen.main.bounds.width - 60) / 2
    
    var body: some View {
        VStack(spacing: 30) {
            // Title
            Text("Essential Tools")
                .font(.system(size: 36, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 60)
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : 20)
            
            // Featured Tools Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                OnboardingToolCard(
                    icon: "viewfinder",
                    title: "Smart Scanner",
                    color: .purple
                )
                
                OnboardingToolCard(
                    icon: "bubble.left.and.bubble.right",
                    title: "AI Chat",
                    color: .blue
                )
                
                OnboardingToolCard(
                    icon: "function",
                    title: "Math Solver",
                    color: .orange
                )
                
                OnboardingToolCard(
                    icon: "text.book.closed",
                    title: "Study Notes",
                    color: .green
                )
            }
            .padding(.horizontal)
            .opacity(animateTools ? 1 : 0)
            .offset(y: animateTools ? 0 : 30)
            
            Spacer()
            
            Text("Powerful Study Tools\nAt Your Fingertips")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
                .opacity(animateTitle ? 1 : 0)
        }
        .foregroundColor(.white)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                animateTools = true
            }
        }
    }
}

struct OnboardingToolCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: (UIScreen.main.bounds.width - 60) / 2)
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(20)
    }
}

// Third Onboarding Page
struct ThirdOnboardingPage: View {
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 15) {
                    ReviewCard(
                        title: "Game Changer!",
                        author: "MathWhiz123",
                        date: "03/15/24",
                        text: "This app completely transformed how I approach my calculus homework. The step-by-step explanations are incredibly detailed and helpful.",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Perfect Study Companion",
                        author: "PhysicsStudent",
                        date: "03/12/24",
                        text: "Not just for math! Helped me understand complex physics problems too. The AI explanations are clear and easy to follow.",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Better Than a Tutor",
                        author: "StudyPro",
                        date: "03/10/24",
                        text: "24/7 help whenever I need it. The app breaks down complex problems into simple steps. Worth every penny!",
                        rating: 5
                    )
                    
                    ReviewCard(
                        title: "Life Saver",
                        author: "ChemistryAce",
                        date: "03/08/24",
                        text: "From balancing equations to stoichiometry, this app has been invaluable for my chemistry studies. Highly recommend!",
                        rating: 5
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Join 1M+\n Students")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .foregroundColor(.white)
    }
}

struct UnifiedOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        UnifiedOnboardingView()
    }
}
