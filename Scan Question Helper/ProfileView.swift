import SwiftUI

struct ProfileView: View {
    @State private var showCameraView = false
    @State private var showOnboarding = false
    @Environment(\.dismiss) private var dismiss
    let deviceId = GlobalContent.shared.deviceId
    
    var body: some View {
        List {
            // Device ID Section
            Section {
                HStack {
                    Text("Device ID")
                        .foregroundColor(.white)
                    Spacer()
                    Text(deviceId)
                        .foregroundColor(.gray)
                        .font(.system(.body, design: .monospaced))
                }
            } header: {
                Text("Device Information")
                    .foregroundColor(.gray)
            }
            

            
            // Sign Out Section
            Section {
                Button(action: {
                    // Clear any stored user data
                    UserDefaults.standard.removeObject(forKey: "isOnboardingComplete")
                    GlobalContent.shared.deviceId = "unknown-\(UUID().uuidString)"
                    
                    // Dismiss current view and show onboarding
                    dismiss()
                    showOnboarding = true
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.red)
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .background(Color.black)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showOnboarding) {
            NavigationStack {
                UnifiedOnboardingView()
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
        }
    }
} 
