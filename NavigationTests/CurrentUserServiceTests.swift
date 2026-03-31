import XCTest
import UIKit
@testable import Navigation

final class CurrentUserServiceTests: XCTestCase {
    private let avatarKey = "currentUser.avatarFileName"
    private let avatarFileName = "current_avatar.jpg"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: avatarKey)
        removeAvatarFileIfNeeded()
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: avatarKey)
        removeAvatarFileIfNeeded()
        super.tearDown()
    }

    func testGetUser_withUnknownLogin_returnsNil() {
        let service = CurrentUserService()

        XCTAssertNil(service.getUser(login: "unknown"))
    }

    func testGetUser_withKnownLogin_returnsExpectedIdentity() {
        let service = CurrentUserService()

        let user = service.getUser(login: "Wowgorno")

        XCTAssertNotNil(user)
        XCTAssertEqual(user?.login, "Wowgorno")
        XCTAssertEqual(user?.fullName, "Maxim Gornostayev")
        XCTAssertEqual(user?.status, "iOS Developer")
    }

    func testUpdateAvatar_savesFileNameAndPersistsImage() {
        let service = CurrentUserService()
        let image = makeImage(color: .red, size: CGSize(width: 48, height: 48))

        service.updateAvatar(image)

        XCTAssertEqual(UserDefaults.standard.string(forKey: avatarKey), avatarFileName)

        let user = service.getUser(login: "Wowgorno")
        XCTAssertNotNil(user)
        XCTAssertGreaterThan(user?.avatar.size.width ?? 0, 0)
        XCTAssertGreaterThan(user?.avatar.size.height ?? 0, 0)
    }

    private func removeAvatarFileIfNeeded() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = url.appendingPathComponent(avatarFileName)
        try? FileManager.default.removeItem(at: fileURL)
    }

    private func makeImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
