import XCTest
@testable import Navigation

final class SettingsStorageTests: XCTestCase {
    private let key = "sortAscending"
    private let themeKey = "themeMode"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: themeKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: themeKey)
        super.tearDown()
    }

    func testIsAscending_whenValueNotStored_returnsTrueByDefault() {
        XCTAssertTrue(SettingsStorage.shared.isAscending)
    }

    func testIsAscending_whenSetFalse_persistsFalse() {
        SettingsStorage.shared.isAscending = false

        XCTAssertFalse(SettingsStorage.shared.isAscending)
        XCTAssertEqual(UserDefaults.standard.object(forKey: key) as? Bool, false)
    }

    func testIsAscending_whenSetTrue_persistsTrue() {
        SettingsStorage.shared.isAscending = true

        XCTAssertTrue(SettingsStorage.shared.isAscending)
        XCTAssertEqual(UserDefaults.standard.object(forKey: key) as? Bool, true)
    }

    func testThemeMode_defaultIsSystem() {
        XCTAssertEqual(SettingsStorage.shared.themeMode, .system)
    }

    func testThemeMode_whenSetDark_persistsDarkRawValue() {
        SettingsStorage.shared.themeMode = .dark

        XCTAssertEqual(SettingsStorage.shared.themeMode, .dark)
        XCTAssertEqual(UserDefaults.standard.integer(forKey: themeKey), AppThemeMode.dark.rawValue)
    }
}
