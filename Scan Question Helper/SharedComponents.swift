import SwiftUI

struct SectionTitle: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToolButton: View {
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
    }
}

struct SubjectButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color)
        .cornerRadius(20)
    }
}

struct ReviewCard: View {
    let title: String?
    let author: String?
    let date: String?
    let text: String
    let rating: Int
    
    init(title: String? = nil, author: String? = nil, date: String? = nil, text: String, rating: Int) {
        self.title = title
        self.author = author
        self.date = date
        self.text = text
        self.rating = rating
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            if let author = author, let date = date {
                HStack {
                    Text("by \(author)")
                        .foregroundColor(.gray)
                    Text("-")
                        .foregroundColor(.gray)
                    Text(date)
                        .foregroundColor(.gray)
                }
                .font(.subheadline)
            }
            
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .padding(.vertical, 4)
            
            // Star Rating
            HStack(spacing: 4) {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
    }
} 
