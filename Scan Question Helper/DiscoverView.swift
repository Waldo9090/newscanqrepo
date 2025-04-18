import SwiftUI

struct DiscoverView: View {
    @State private var showCameraView = false
    @State private var showChatView = false
    @State private var selectedMode: ChatMode? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    StudyToolsSection(showCameraView: $showCameraView, showChatView: $showChatView, selectedMode: $selectedMode)
                    QuickActionsSection(showChatView: $showChatView, selectedMode: $selectedMode)
                    FeaturedToolsSection(showChatView: $showChatView, selectedMode: $selectedMode)
                }
                .padding(.vertical)
            }
            .background(Color.black)
            .navigationTitle("Explore")
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView()
            }
            .sheet(isPresented: $showChatView) {
                ChatDetailView(mode: selectedMode)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct StudyToolsSection: View {
    @Binding var showCameraView: Bool
    @Binding var showChatView: Bool
    @Binding var selectedMode: ChatMode?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Study Tools", subtitle: "Essential tools for your learning journey")
            
            HStack(spacing: 15) {
                Button(action: {
                    showCameraView = true
                }) {
                    ToolCard(
                        icon: "viewfinder",
                        title: "Smart Scanner",
                        subtitle: "Solve problems\nby photo",
                        color: Color.purple.opacity(0.8)
                    )
                }
                
                Button(action: {
                    selectedMode = .write
                    showChatView = true
                }) {
                    ToolCard(
                        icon: "bubble.left.and.bubble.right",
                        title: "AI Chat",
                        subtitle: "Get step-by-step\nhelp instantly",
                        color: Color.blue.opacity(0.8)
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct QuickActionsSection: View {
    @Binding var showChatView: Bool
    @Binding var selectedMode: ChatMode?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Quick Actions", subtitle: "Solve problems instantly")
            
            VStack(spacing: 12) {
                QuickActionRow(
                    button1: ("Math", "function", Color(hex: "#FF3B30")),
                    button2: ("Physics", "atom", Color(hex: "#007AFF")),
                    showChatView: $showChatView,
                    selectedMode: $selectedMode
                )
                
                QuickActionRow(
                    button1: ("Chemistry", "flask", Color(hex: "#FF9500")),
                    button2: ("Biology", "leaf", Color(hex: "#34C759")),
                    showChatView: $showChatView,
                    selectedMode: $selectedMode
                )
                
                QuickActionRow(
                    button1: ("History", "book", Color(hex: "#5856D6")),
                    button2: ("Literature", "text.quote", Color(hex: "#FF2D55")),
                    showChatView: $showChatView,
                    selectedMode: $selectedMode
                )
                
                QuickActionRow(
                    button1: ("Geography", "globe", Color(hex: "#5AC8FA")),
                    button2: ("Economics", "chart.bar", Color(hex: "#FF9500")),
                    showChatView: $showChatView,
                    selectedMode: $selectedMode
                )
                
                QuickActionRow(
                    button1: ("Computer Science", "laptopcomputer", Color(hex: "#5856D6")),
                    button2: ("Psychology", "brain", Color(hex: "#FF3B30")),
                    showChatView: $showChatView,
                    selectedMode: $selectedMode
                )
            }
        }
        .padding(.horizontal)
    }
}

struct QuickActionRow: View {
    let button1: (title: String, icon: String, color: Color)
    let button2: (title: String, icon: String, color: Color)
    @Binding var showChatView: Bool
    @Binding var selectedMode: ChatMode?
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                selectedMode = .write
                showChatView = true
            }) {
                QuickActionButton(
                    title: button1.title,
                    icon: button1.icon,
                    color: button1.color,
                    action: {}
                )
            }
            
            Button(action: {
                selectedMode = .write
                showChatView = true
            }) {
                QuickActionButton(
                    title: button2.title,
                    icon: button2.icon,
                    color: button2.color,
                    action: {}
                )
            }
        }
    }
}

struct FeaturedToolsSection: View {
    @Binding var showChatView: Bool
    @Binding var selectedMode: ChatMode?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            SectionHeader(title: "Featured Tools", subtitle: "Popular learning resources")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Button(action: {
                        selectedMode = .write
                        showChatView = true
                    }) {
                        FeaturedToolCard(
                            title: "Simple Answers",
                            icon: "list.bullet.rectangle",
                            color: Color(hex: "#FF9F1C")
                        )
                    }
                    
                    Button(action: {
                        selectedMode = .write
                        showChatView = true
                    }) {
                        FeaturedToolCard(
                            title: "Practice Questions",
                            icon: "pencil.and.outline",
                            color: Color(hex: "#2EC4B6")
                        )
                    }
                    
                    Button(action: {
                        selectedMode = .write
                        showChatView = true
                    }) {
                        FeaturedToolCard(
                            title: "Study Notes",
                            icon: "note.text",
                            color: Color(hex: "#E71D36")
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

struct ToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color)
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
        }
    }
}

struct FeaturedToolCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
        }
        .frame(width: 160)
        .padding()
        .background(color)
        .cornerRadius(20)
        .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct SectionHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
}

// Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
