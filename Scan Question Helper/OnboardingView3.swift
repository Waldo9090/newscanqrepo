import SwiftUI

struct OnboardingView3: View {
    var body: some View {
        VStack(spacing: 20) {
            ScrollView {
                VStack(spacing: 15) {
                    // Review Card 1
                    ReviewCard(
                        text: "This helped me help my daughter with her homework !!! We went thru all the steps and got her home work done in no time",
                        rating: 5
                    )
                    
                    // Review Card 2
                    ReviewCard(
                        title: "Thanks!",
                        author: "Margot 🐷",
                        date: "09/27/2023",
                        text: "It helped me really well not only with giving answers but explaining how to find the answer.",
                        rating: 5
                    )
                    
                    // Review Card 3
                    ReviewCard(
                        title: "Definitely a must",
                        author: "MeloMamba",
                        date: "10/23/2023",
                        text: "Definitely does what it says. Awesome app fast results. Checking work a super breeze now!!!",
                        rating: 5
                    )
                    
                    // Review Card 4
                    ReviewCard(
                        title: "Classwork",
                        author: "El_pero_dotty",
                        date: "10/26/2023",
                        text: "I was not doing anything for 2 months and somehow bounced back, thank you Solvo.",
                        rating: 5
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Title
            Text("Join 1M\nHappy Users")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)
            
            // Page Indicator
            PageIndicator(currentPage: 2, totalPages: 3)
            
            // Navigation Button
            NavigationLink(destination: TabBarView().navigationBarBackButtonHidden(true)) {
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


struct OnboardingView3_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView3()
    }
}
