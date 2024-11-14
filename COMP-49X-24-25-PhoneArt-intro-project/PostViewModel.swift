import Foundation
import FirebaseFirestore

public struct Post: Identifiable {
    public let id: UUID
    public let content: String
    public let timestamp: Date

    public init(id: UUID = UUID(), content: String, timestamp: Date) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
    }
}

public class PostViewModel: ObservableObject {
    @Published public var posts: [Post] = []
    private let db = Firestore.firestore()

    public init() {
        fetchPosts() // Fetch posts when the view model is initialized
    }

    // Make fetchPosts public so it can be called from ContentView
    public func fetchPosts() {
        db.collection("posts").order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching posts: \(error.localizedDescription)")
                return
            }
            self.posts = snapshot?.documents.compactMap { document -> Post? in
                let data = document.data()
                guard let content = data["content"] as? String,
                      let timestamp = data["timestamp"] as? Timestamp else {
                    return nil
                }
                return Post(id: UUID(), content: content, timestamp: timestamp.dateValue())
            } ?? []
        }
    }

    // Function to add a new post to Firestore
    public func addPost(content: String) {
        let postRef = db.collection("posts").document()
        let post = [
            "id": postRef.documentID,
            "content": content,
            "timestamp": Date()
        ] as [String: Any]

        postRef.setData(post) { error in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                print("New post added: \(content)")
                self.fetchPosts() // Refresh posts after adding a new one
            }
        }
    }
}
