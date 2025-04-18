import SwiftUI

struct ChatListView: View {
    @State private var showNewChat = false
    @State private var messageText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Points capsule only

            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Bot messages with avatar
                    VStack(alignment: .leading, spacing: 12) {
                        // Avatar and greeting
                        HStack(alignment: .bottom, spacing: 8) {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                )
                            
                            MessageBubble(message: "Hi! 👋", isBot: true)
                        }
                        
                        // Follow-up message without avatar
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 32)
                            
                            MessageBubble(message: "Tap the input box to get started.", isBot: true)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Task options
                    VStack(alignment: .leading, spacing: 12) {
                        TaskButton(
                            title: "Write",
                            icon: "pencil",
                            color: .yellow
                        )
                        
                        TaskButton(
                            title: "Improve",
                            icon: "pencil.and.outline",
                            color: .pink
                        )
                        
                        TaskButton(
                            title: "Summarize",
                            icon: "text.book.closed",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 8)
            }
            
            // Input field
            VStack {
                Button(action: {
                    showNewChat = true
                }) {
                    HStack {
                        Text("Ask anything...")
                            .foregroundColor(.gray)
                        Spacer()
                        
                        Image(systemName: "sparkles")
                            .foregroundColor(.purple)
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding()
            }
            .background(Color.black.opacity(0.6))
        }
        .background(Color.black)
        .sheet(isPresented: $showNewChat) {
            ChatDetailView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct MessageBubble: View {
    let message: String
    let isBot: Bool
    
    var body: some View {
        Text(message)
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                isBot ? Color(UIColor.systemGray6).opacity(0.2) : Color.purple.opacity(0.7)
            )
            .cornerRadius(20)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isBot ? .leading : .trailing)
    }
}

struct TaskButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(width: 32)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(color.opacity(0.7))
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(16)
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChatListView()
        }
    }
} 
