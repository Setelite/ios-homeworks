import Foundation

struct FirestoreFieldValue: Codable {
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
