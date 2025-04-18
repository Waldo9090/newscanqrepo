import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.purple.opacity(0.8) : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(page == currentPage ? 1.2 : 1.0)
                    .animation(.spring(), value: currentPage)
            }
        }
        .padding(.vertical, 20)
    }
} 