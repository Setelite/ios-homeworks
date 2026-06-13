import Foundation

struct SocialFeedPost: Codable, Equatable {
    let id: String
    let username: String
    let avatarURL: URL?
    let photoURL: URL?
    let caption: String
    let date: Date
}
