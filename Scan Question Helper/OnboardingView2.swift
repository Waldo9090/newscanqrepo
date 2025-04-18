import SwiftUI
import UserNotifications

struct OnboardingView2: View {
    let subjects = [
        ("Math Problems", "function", Color.red.opacity(0.8)),
        ("Quizzes & Tests", "checkmark.square.fill", Color.blue.opacity(0.8)),
        ("Physics", "atom", Color.green.opacity(0.8)),
        ("Biology", "leaf.fill", Color.purple.opacity(0.8)),
        ("Chemistry", "flask.fill", Color.orange.opacity(0.8))
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Top Tools Section
            VStack(spacing: 15) {
                Text("Essential Tools")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                // Scanner and Chat
                HStack(spacing: 15) {
                    ToolButton(
                        icon: "viewfinder.circle.fill",
                        title: "Scanner",
                        subtitle: "Snap your task\nfor answers",
                        color: Color.purple.opacity(0.8)
                    )
                    ToolButton(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Chat",
                        subtitle: "Tackle writing\nand other tasks",
                        color: Color.blue.opacity(0.8)
                    )
                }
                .padding(.horizontal)
            }
            
            // Subjects Section
            VStack(spacing: 15) {
                Text("Study Subjects")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                // Subject Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    ForEach(subjects, id: \.0) { subject in
                        SubjectButton(
                            icon: subject.1,
                            title: subject.0,
                            color: subject.2
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Title and Description
            Text("Conquer Any Task\nwith Powerful\nStudy Tools")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
            // Page Indicator
            PageIndicator(currentPage: 1, totalPages: 3)
            
            // Navigation Button
            NavigationLink(destination: OnboardingView3().navigationBarBackButtonHidden(true)) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple.opacity(0.8))
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.black)
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
}



struct OnboardingView2_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView2()
    }
}
