//
//  ChatBotView.swift
//  AI Homework Helper
//
//  Created by Ayush Mahna on 2/2/25.
//

import SwiftUI

// MARK: - Message Model

/// A simple model representing a message in the chat.
/// It now supports either text or an image (stored as Data).
struct Message: Identifiable, Codable, Equatable {
    let id: UUID = UUID()
    var text: String?
    let isUser: Bool
    // Store image data for messages that include an image.
    var imageData: Data? = nil
    
    /// A computed property to get a UIImage from imageData.
    var image: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }
}

// MARK: - OpenAI API Response Models

// For non-streaming responses (if needed)
struct ChatGPTResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: APIMessage
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

// --- ADDED: For STREAMING responses ---
struct ChatGPTStreamResponse: Decodable {
    let choices: [StreamChoice]
}

struct StreamChoice: Decodable {
    let delta: Delta
}

struct Delta: Decodable {
    let content: String?
}
// --- END ADDED ---


// MARK: - StreamingDelegate (Moved here and made non-private)

/// A custom URLSessionDataDelegate that processes streaming responses from the OpenAI API.
class StreamingDelegate: NSObject, URLSessionDataDelegate {
    var onReceiveChunk: (String) -> Void
    var onCompletion: () -> Void
    var dataBuffer: String = ""
    
    init(onReceiveChunk: @escaping (String) -> Void,
         onCompletion: @escaping () -> Void) {
        self.onReceiveChunk = onReceiveChunk
        self.onCompletion = onCompletion
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunkString = String(data: data, encoding: .utf8) else { return }
        
        dataBuffer += chunkString
        let lines = dataBuffer.components(separatedBy: "\n")
        dataBuffer = lines.last ?? ""
        
        for line in lines.dropLast() {
            if line.hasPrefix("data: ") {
                let jsonString = String(line.dropFirst(6))
                if jsonString == "[DONE]" {
                    DispatchQueue.main.async { self.onCompletion() }
                    return
                }
                if let jsonData = jsonString.data(using: .utf8) {
                    do {
                        // Use the correctly defined stream response struct
                        let streamResponse = try JSONDecoder().decode(ChatGPTStreamResponse.self, from: jsonData)
                        if let content = streamResponse.choices.first?.delta.content {
                            DispatchQueue.main.async { self.onReceiveChunk(content) }
                        }
                    } catch {
                        print("Failed to decode stream response: \(error) - JSON: \(jsonString)")
                    }
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Stream completed with error: \(error)")
        }
        DispatchQueue.main.async { self.onCompletion() }
    }
}

// --- ADDED: Helper function to load API key from Secrets.plist ---
// Placed outside structs/classes for global accessibility within the module
func loadAPIKey() -> String? {
    guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
          let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject],
          let key = dict["OpenAIAPIKey"] as? String else {
        print("Error: Could not load API key from Secrets.plist. Make sure the file exists and the key 'OpenAIAPIKey' is set.")
        return nil
    }
    return key
}
// --- END ADDED ---


// MARK: - ChatBotView

struct ChatBotView: View {
    let systemPrompt: String
    let initialMessage: String
    /// If there is an existing chat history, load it; otherwise start fresh.
    let existingChatHistory: [Message]?
    
    // A unique key for storing this chat's history.
    private let chatStorageKey: String = UUID().uuidString
    
    @State private var messages: [Message] = []
    @State private var userInput: String = ""
    @State private var isLoading: Bool = false  // Used for disabling input while streaming.
    
    // For image picker presentation.
    @State private var isShowingImagePicker: Bool = false
    // Holds the image selected from the image picker.
    @State private var selectedImage: UIImage? = nil
    // Tracks the image picker source type: camera or photo library.
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    // The ID of the bot message that is currently streaming its response.
    @State private var currentBotMessageID: UUID? = nil
    
    // Optionally, show an alert if the camera is not available.
    @State private var showCameraAlert: Bool = false

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageRowView(message: message, currentBotMessageID: currentBotMessageID) {
                                messageContentView(message: message)
                            }
                            .id(message.id)
                        }
                        
                        if isLoading && currentBotMessageID == nil {
                            ProgressView()
                                .padding()
                        }
                    }
                    .onChange(of: messages) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Divider()
                .padding(.horizontal)
            
            // Input area with a menu button for attaching or taking photos.
            HStack {
                Menu {
                    Button("Attach Photo") {
                        imagePickerSource = .photoLibrary
                        isShowingImagePicker = true
                    }
                    Button("Take Photo") {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            imagePickerSource = .camera
                            // Delay sheet presentation to ensure imagePickerSource is updated.
                            DispatchQueue.main.async {
                                isShowingImagePicker = true
                            }
                        } else {
                            showCameraAlert = true
                        }
                    }
                } label: {
                    Image(systemName: "paperclip")
                        .font(.title2)
                }
                .padding(.trailing, 4)
                
                TextField("Type your message...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("Chat Tutor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadChatHistory()
            if messages.isEmpty {
                let initial = Message(text: initialMessage, isUser: false)
                messages.append(initial)
            }
        }
        .onDisappear {
            saveChatHistory()
        }

        .alert(isPresented: $showCameraAlert) {
            Alert(title: Text("Camera Unavailable"),
                  message: Text("The camera is not available on this device."),
                  dismissButton: .default(Text("OK")))
        }
        .background(Color(UIColor.systemBackground))
    }
    
    /// Returns a view displaying either text or an image for a message.
    @ViewBuilder
    private func messageContentView(message: Message) -> some View {
        if let image = message.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .frame(maxWidth: 200, maxHeight: 200)
        } else if let text = message.text {
            Text(text)
                .padding()
                .background(message.isUser ? Color.blue.opacity(0.7) : Color.gray.opacity(0.3))
                .foregroundColor(message.isUser ? .white : .black)
                .cornerRadius(10)
        }
    }
    
    /// Called when the image picker is dismissed.
    private func imagePickerDismissed() {
        if let image = selectedImage {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let imageMessage = Message(text: nil, isUser: true, imageData: imageData)
                messages.append(imageMessage)
                
                let placeholderText = "Use this image for context."
                let messageWithPlaceholder = Message(text: placeholderText, isUser: true)
                messages.append(messageWithPlaceholder)
                
                fetchBotResponse()
            }
            selectedImage = nil
        }
    }
    
    /// Sends the user message (if any) and calls the OpenAI API for a response.
    private func sendMessage() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }
        
        let userMessage = Message(text: trimmedInput, isUser: true)
        messages.append(userMessage)
        userInput = ""
        
        fetchBotResponse()
    }
    
    /// Calls the OpenAI API using the chat history and system prompt with streaming enabled.
    private func fetchBotResponse() {
        // --- Load API Key using shared function ---
        guard let apiKey = loadAPIKey() else {
            print("Error: API Key not found in Secrets.plist for ChatBotView.")
            // Handle the error appropriately in the UI if needed, e.g., show an alert
            // For now, just stop loading and return
            isLoading = false
            return
        }
        // --- End Load API Key ---

        isLoading = true
        
        var apiMessages: [[String: String]] = [
            [
                "role": "system",
                "content": systemPrompt
            ]
        ]
        
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            let content: String
            if let text = message.text {
                content = text
            } else if message.imageData != nil {
                content = "[User sent an image]" // Simplified representation for non-vision models
            } else {
                content = ""
            }
            apiMessages.append([
                "role": role,
                "content": content
            ])
        }
        
        let streamingMessage = Message(text: "", isUser: false)
        messages.append(streamingMessage)
        currentBotMessageID = streamingMessage.id
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid URL")
            isLoading = false
            // Maybe update a message here too?
            // updateBotMessage(with: "Internal Error: Invalid API URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Use the loaded apiKey from Secrets.plist via loadAPIKey()
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o", // Ensure this model supports the message format
            "messages": apiMessages,
            "temperature": 0.7,
            "stream": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Error encoding body: \(error)")
            isLoading = false
            // Maybe update a message here too?
            // updateBotMessage(with: "Internal Error: Could not encode request")
            return
        }
        
        // Use the globally accessible StreamingDelegate
        let delegate = StreamingDelegate(
            onReceiveChunk: { chunk in
                if let index = self.messages.firstIndex(where: { $0.id == self.currentBotMessageID }) {
                    self.messages[index].text = (self.messages[index].text ?? "") + chunk
                }
            },
            onCompletion: {
                self.isLoading = false
                self.currentBotMessageID = nil
            }
        )
        
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        task.resume()
    }
    
    /// Saves the chat history to UserDefaults.
    private func saveChatHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(messages)
            UserDefaults.standard.set(data, forKey: chatStorageKey)
            print("Chat history saved with key: \(chatStorageKey)")
        } catch {
            print("Failed to save chat history: \(error)")
        }
    }
    
    /// Loads the chat history from UserDefaults, if available.
    private func loadChatHistory() {
        if let data = UserDefaults.standard.data(forKey: chatStorageKey) {
            do {
                let decoder = JSONDecoder()
                let savedMessages = try decoder.decode([Message].self, from: data)
                messages = savedMessages
            } catch {
                print("Failed to load chat history: \(error)")
            }
        } else if let existingHistory = existingChatHistory {
            messages = existingHistory
        }
    }
    
    // ADDED: Helper to update bot message for errors in ChatBotView
    private func updateBotMessage(with text: String) {
        if let index = messages.firstIndex(where: { $0.id == currentBotMessageID }) {
            messages[index].text = text
        } else {
            // Avoid adding duplicate error messages if key load failed
            if !messages.contains(where: { $0.text == text && !$0.isUser }) {
                 messages.append(Message(text: text, isUser: false))
            }
        }
        isLoading = false
        currentBotMessageID = nil
    }
}

// MARK: - MessageRowView

/// A subview that renders a single message row.
/// This helps break up the code and assists the compiler with type-checking.
struct MessageRowView<Content: View>: View {
    let message: Message
    let currentBotMessageID: UUID?
    let content: () -> Content

    var body: some View {
        Group {
            if message.isUser {
                HStack {
                    Spacer()
                    content()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                }
                .padding(.horizontal)
            } else {
                HStack(alignment: .bottom, spacing: 8) {
                    content()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                    
                    if message.id == currentBotMessageID {
                        TypingIndicatorView()
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - TypingIndicatorView

/// A simple view showing a pulsing circle to indicate that the bot is typing.
struct TypingIndicatorView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.5

    var body: some View {
        Circle()
            .fill(Color.gray)
            .frame(width: 10, height: 10)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
    }
}

// MARK: - ImagePicker

/// A wrapper for UIImagePickerController to select images.
/// Now accepts a sourceType parameter to allow for the camera or photo library.

// MARK: - ChatBotView_Previews


