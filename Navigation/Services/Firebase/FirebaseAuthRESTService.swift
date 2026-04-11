import Foundation

struct FirebaseAuthenticatedUser: Equatable {
    let email: String
    let displayName: String?
    let photoURL: String?
}

struct FirebaseAuthSession: Equatable {
    let idToken: String
    let refreshToken: String
    let user: FirebaseAuthenticatedUser
}

protocol FirebaseAuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> FirebaseAuthSession
    func signUp(email: String, password: String) async throws -> FirebaseAuthSession
}

final class FirebaseSessionStorage {
    static let shared = FirebaseSessionStorage()

    private enum Keys {
        static let idToken = "firebase.session.idToken"
        static let refreshToken = "firebase.session.refreshToken"
        static let email = "firebase.session.email"
        static let displayName = "firebase.session.displayName"
        static let photoURL = "firebase.session.photoURL"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isAuthorized: Bool {
        token != nil
    }

    var token: String? {
        defaults.string(forKey: Keys.idToken)
    }

    var user: FirebaseAuthenticatedUser? {
        guard let email = defaults.string(forKey: Keys.email) else { return nil }
        return FirebaseAuthenticatedUser(
            email: email,
            displayName: defaults.string(forKey: Keys.displayName),
            photoURL: defaults.string(forKey: Keys.photoURL)
        )
    }

    func store(session: FirebaseAuthSession) {
        defaults.set(session.idToken, forKey: Keys.idToken)
        defaults.set(session.refreshToken, forKey: Keys.refreshToken)
        defaults.set(session.user.email, forKey: Keys.email)
        defaults.set(session.user.displayName, forKey: Keys.displayName)
        defaults.set(session.user.photoURL, forKey: Keys.photoURL)
    }

    func clear() {
        defaults.removeObject(forKey: Keys.idToken)
        defaults.removeObject(forKey: Keys.refreshToken)
        defaults.removeObject(forKey: Keys.email)
        defaults.removeObject(forKey: Keys.displayName)
        defaults.removeObject(forKey: Keys.photoURL)
    }
}

final class FirebaseAuthRESTService: FirebaseAuthServiceProtocol {
    private struct AuthRequest: Encodable {
        let email: String
        let password: String
        let returnSecureToken = true
    }

    private struct AuthResponse: Decodable {
        let idToken: String
        let refreshToken: String
        let email: String
    }

    private struct LookupRequest: Encodable {
        let idToken: String
    }

    private struct LookupResponse: Decodable {
        struct UserData: Decodable {
            let email: String?
            let displayName: String?
            let photoUrl: String?
        }

        let users: [UserData]
    }

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuthSession {
        try await authenticate(path: "accounts:signInWithPassword", email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> FirebaseAuthSession {
        try await authenticate(path: "accounts:signUp", email: email, password: password)
    }

    private func authenticate(path: String, email: String, password: String) async throws -> FirebaseAuthSession {
        let apiKey = try firebaseAPIKey()
        let authResponse: AuthResponse = try await performRequest(
            path: path,
            apiKey: apiKey,
            body: AuthRequest(email: email, password: password)
        )

        let profile = try await lookupUser(idToken: authResponse.idToken, apiKey: apiKey)
        return FirebaseAuthSession(
            idToken: authResponse.idToken,
            refreshToken: authResponse.refreshToken,
            user: FirebaseAuthenticatedUser(
                email: profile?.email ?? authResponse.email,
                displayName: profile?.displayName,
                photoURL: profile?.photoUrl
            )
        )
    }

    private func lookupUser(idToken: String, apiKey: String) async throws -> LookupResponse.UserData? {
        let response: LookupResponse = try await performRequest(
            path: "accounts:lookup",
            apiKey: apiKey,
            body: LookupRequest(idToken: idToken)
        )

        return response.users.first
    }

    private func performRequest<Body: Encodable, Output: Decodable>(
        path: String,
        apiKey: String,
        body: Body
    ) async throws -> Output {
        let endpoint = "https://identitytoolkit.googleapis.com/v1/\(path)?key=\(apiKey)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw URLError(.userAuthenticationRequired)
        }

        return try decoder.decode(Output.self, from: data)
    }

    private func firebaseAPIKey() throws -> String {
        guard
            let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
            let info = NSDictionary(contentsOfFile: path),
            let key = info["API_KEY"] as? String,
            !key.isEmpty
        else {
            throw URLError(.cannotFindHost)
        }

        return key
    }
}
