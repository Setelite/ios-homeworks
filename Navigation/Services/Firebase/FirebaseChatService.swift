import Foundation

struct ChatDialog {
    let peerName: String
    let roomID: String
    let lastMessage: String
    let time: String
}

struct ChatAPIMessage {
    let id: String
    let sender: String
    let text: String
    let sentAt: Date
}

protocol FirebaseChatServiceProtocol {
    func fetchDialogs(currentUser: String, peers: [String], token: String) async throws -> [ChatDialog]
    func fetchMessages(roomID: String, token: String) async throws -> [ChatAPIMessage]
    func sendMessage(roomID: String, sender: String, text: String, token: String) async throws
}

final class FirebaseChatService: FirebaseChatServiceProtocol {
    private struct DocumentsResponse: Decodable {
        struct Document: Decodable {
            let name: String
            let fields: [String: FirestoreFieldValue]?
        }

        let documents: [Document]?
    }

    private struct PatchRequest: Encodable {
        let fields: [String: FirestoreFieldValue]
    }

    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchDialogs(currentUser: String, peers: [String], token: String) async throws -> [ChatDialog] {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        var dialogs: [ChatDialog] = []
        for peer in peers {
            let roomID = Self.roomID(currentUser: currentUser, peer: peer)
            let messages = try await fetchMessages(roomID: roomID, token: token)
            let last = messages.last
            dialogs.append(
                ChatDialog(
                    peerName: peer,
                    roomID: roomID,
                    lastMessage: last?.text ?? L10n.tr("chat.placeholder.no_messages"),
                    time: last.map { formatter.string(from: $0.sentAt) } ?? ""
                )
            )
        }

        return dialogs
    }

    func fetchMessages(roomID: String, token: String) async throws -> [ChatAPIMessage] {
        let projectID = try firebaseProjectID()
        var components = URLComponents(url: messagesCollectionURL(projectID: projectID, roomID: roomID), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "pageSize", value: "100")]

        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotLoadFromNetwork)
        }

        let payload = try decoder.decode(DocumentsResponse.self, from: data)

        let mapped: [ChatAPIMessage] = (payload.documents ?? []).compactMap { document in
            guard let fields = document.fields else { return nil }

            let sentAtString = fields["sentAt"]?.timestampValue
                ?? fields["createdAt"]?.timestampValue
                ?? ISO8601DateFormatter().string(from: Date())

            let sentAt = ISO8601DateFormatter().date(from: sentAtString) ?? Date()

            return ChatAPIMessage(
                id: document.name,
                sender: fields["sender"]?.stringValue ?? "",
                text: fields["text"]?.stringValue ?? "",
                sentAt: sentAt
            )
        }

        return mapped.sorted(by: { $0.sentAt < $1.sentAt })
    }

    func sendMessage(roomID: String, sender: String, text: String, token: String) async throws {
        let projectID = try firebaseProjectID()
        let messageID = UUID().uuidString
        let url = try messageDocumentURL(projectID: projectID, roomID: roomID, messageID: messageID)

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.timeoutInterval = 8
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = PatchRequest(fields: [
            "sender": .string(sender),
            "text": .string(text),
            "sentAt": .timestamp(ISO8601DateFormatter().string(from: Date()))
        ])

        request.httpBody = try encoder.encode(body)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.cannotWriteToFile)
        }
    }

    static func roomID(currentUser: String, peer: String) -> String {
        let left = normalizedUserID(currentUser)
        let right = normalizedUserID(peer)
        return [left, right].sorted().joined(separator: "__")
    }

    static func normalizedUserID(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let lowered = value.lowercased()
        let mapped = lowered.unicodeScalars.map { allowed.contains($0) ? Character($0) : "_" }
        return String(mapped)
    }

    private func firebaseProjectID() throws -> String {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let info = NSDictionary(contentsOfFile: path),
            let projectID = info["PROJECT_ID"] as? String,
            !projectID.isEmpty
        else {
            throw URLError(.cannotFindHost)
        }
        return projectID
    }

    private func messagesCollectionURL(projectID: String, roomID: String) -> URL {
        URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/chat_rooms/\(roomID)/messages")!
    }

    private func messageDocumentURL(projectID: String, roomID: String, messageID: String) throws -> URL {
        guard let encodedRoom = roomID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let encodedMessage = messageID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/chat_rooms/\(encodedRoom)/messages/\(encodedMessage)")
        else {
            throw URLError(.badURL)
        }
        return url
    }
}

private struct FirestoreFieldValue: Codable {
    let stringValue: String?
    let timestampValue: String?

    init(stringValue: String? = nil, timestampValue: String? = nil) {
        self.stringValue = stringValue
        self.timestampValue = timestampValue
    }

    static func string(_ value: String) -> FirestoreFieldValue {
        FirestoreFieldValue(stringValue: value)
    }

    static func timestamp(_ value: String) -> FirestoreFieldValue {
        FirestoreFieldValue(timestampValue: value)
    }
}
