import SwiftUI

// Example of your first page view
struct FirstPageView: View {
    var body: some View {
        VStack {
            Text("Welcome to the First Page!")
                .font(.largeTitle)
                .padding()
            // Add your first page UI here
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    // Use AppStorage to keep track of the sign in state
    @AppStorage("isSignedIn") var isSignedIn: Bool = true
    // State variable to trigger navigation to FirstPageView
    @State private var navigateToFirstPage: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Define the URLs for Terms & Conditions and Privacy Policy
    private let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    private let privacyPolicyURL = URL(string: "https://waldo9090.github.io/Privacy-Policy/")!
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Legal Section with Terms & Conditions and Privacy Policy
                    Section(header: Text("Legal")
                                .font(.headline)
                                .foregroundColor(.white)) {
                        Button(action: {
                            openURL(termsOfUseURL)
                        }) {
                            HStack {
                                Text("Terms & Conditions")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                        
                        Button(action: {
                            openURL(privacyPolicyURL)
                        }) {
                            HStack {
                                Text("Privacy Policy")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.black)
                    
                    // Account Section
                    // Add your Account-related views here
                }
                .scrollContentBackground(.hidden)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .listStyle(InsetGroupedListStyle())
                
                // Customized Capsule "Delete Account" Button
                Button(action: {
                    // Only update sign in state
                    isSignedIn = false
                    
                    // Dismiss current view and navigate to first page
                    dismiss()
                    navigateToFirstPage = true
                }) {
                    Text("Delete Account")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .background(Color.black)
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 2)
                )
                .clipShape(Capsule())
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                // Hidden NavigationLink that becomes active when navigateToFirstPage is true.
                NavigationLink(destination: StartPageView().navigationBarBackButtonHidden(true),
                               isActive: $navigateToFirstPage) {
                    EmptyView()
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
