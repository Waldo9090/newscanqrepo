import SwiftUI
import FirebaseFirestore

struct HistoryView: View {
    @State private var selectedTab = 0
    @State private var allProblems: [Problem] = []
    @State private var savedProblems: [Problem] = []
    @State private var isLoading = true
    
    struct Problem: Identifiable {
        let id: String
        let image: String
        let solution: String
        let timestamp: Date
        let bookmark: Bool
        
        var formattedDate: String {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: timestamp)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("All").tag(0)
                    Text("Saved").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(selectedTab == 0 ? allProblems : savedProblems) { problem in
                                NavigationLink(destination: HistoryDetailView(problem: problem)) {
                                    ProblemCard(problem: problem)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                fetchProblems()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func fetchProblems() {
        let deviceId = GlobalContent.shared.deviceId
        guard !deviceId.starts(with: "unknown-") else { return }
        
        let db = Firestore.firestore()
        let problemsRef = db.collection("solutions")
            .document(deviceId)
            .collection("problems")
        
        problemsRef.order(by: "timestamp", descending: true)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching problems: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                
                allProblems = documents.compactMap { document -> Problem? in
                    let data = document.data()
                    guard let image = data["image"] as? String,
                          let solution = data["solution"] as? String,
                          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue(),
                          let bookmark = data["bookmark"] as? Bool else {
                        return nil
                    }
                    
                    return Problem(
                        id: document.documentID,
                        image: image,
                        solution: solution,
                        timestamp: timestamp,
                        bookmark: bookmark
                    )
                }
                
                savedProblems = allProblems.filter { $0.bookmark }
                isLoading = false
            }
    }
}

struct ProblemCard: View {
    let problem: HistoryView.Problem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Display image
            if let imageData = Data(base64Encoded: problem.image),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(12)
                    .frame(maxHeight: 200)
            }
            
            // Display timestamp
            Text(problem.formattedDate)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.2))
        .cornerRadius(16)
    }
}

struct HistoryDetailView: View {
    let problem: HistoryView.Problem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Display image
                if let imageData = Data(base64Encoded: problem.image),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .frame(maxHeight: 300)
                        .padding(.horizontal)
                }
                
                // Display solution
                VStack(alignment: .leading, spacing: 12) {
                    Text("Solution")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(problem.solution)
                        .font(.body)
                        .padding(.horizontal)
                }
                
                // Display timestamp
                Text(problem.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Problem Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HistoryView()
}
