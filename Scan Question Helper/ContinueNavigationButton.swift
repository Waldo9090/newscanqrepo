import SwiftUI
import UserNotifications

// MARK: - Standard Continue Button
struct ContinueNavigationButton<Destination: View>: View {
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Spacer()
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 75)
            .background(Color.purple)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .simultaneousGesture(TapGesture().onEnded {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        })
    }
}




struct ContinueButton: View {
    var title: String = "Continue"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 75)
            .background(Color.purple)
            .cornerRadius(15)
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .simultaneousGesture(TapGesture().onEnded {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        })
    }
}

