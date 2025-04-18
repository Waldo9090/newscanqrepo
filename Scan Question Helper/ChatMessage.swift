import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    let isUser: Bool
    let role: String
    
    init(content: String, isUser: Bool) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.role = isUser ? "user" : "assistant"
    }
    
    // For API responses
    init(role: String, content: String) {
        self.id = UUID()
        self.content = content
        self.role = role
        self.isUser = role == "user"
    }
}
