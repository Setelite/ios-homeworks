import XCTest
@testable import Navigation

final class CheckerServiceTests: XCTestCase {
    private final class AuthServiceMock: FirebaseAuthServiceProtocol {
        var signInError: Error?
        var signUpError: Error?

        func signIn(email: String, password: String) async throws -> FirebaseAuthSession {
            if let signInError { throw signInError }
            return FirebaseAuthSession(
                idToken: "id-token",
                refreshToken: "refresh-token",
                user: FirebaseAuthenticatedUser(email: email, displayName: "Tester", photoURL: nil)
            )
        }

        func signUp(email: String, password: String) async throws -> FirebaseAuthSession {
            if let signUpError { throw signUpError }
            return FirebaseAuthSession(
                idToken: "id-token",
                refreshToken: "refresh-token",
                user: FirebaseAuthenticatedUser(email: email, displayName: "Tester", photoURL: nil)
            )
        }
    }

    func testCheckCredentials_whenEmailAndPasswordAreNotEmpty_returnsSuccess() {
        let service = CheckerService(authService: AuthServiceMock(), sessionStorage: FirebaseSessionStorage(defaults: UserDefaults()))
        let exp = expectation(description: "checkCredentials")

        service.checkCredentials(email: "user@example.com", password: "1234") { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testCheckCredentials_whenEmailIsEmpty_returnsFailure() {
        let service = CheckerService(authService: AuthServiceMock(), sessionStorage: FirebaseSessionStorage(defaults: UserDefaults()))
        let exp = expectation(description: "checkCredentials")

        service.checkCredentials(email: "", password: "1234") { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testCheckCredentials_whenPasswordIsEmpty_returnsFailure() {
        let service = CheckerService(authService: AuthServiceMock(), sessionStorage: FirebaseSessionStorage(defaults: UserDefaults()))
        let exp = expectation(description: "checkCredentials")

        service.checkCredentials(email: "user@example.com", password: "") { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSignUp_returnsSuccess() {
        let service = CheckerService(authService: AuthServiceMock(), sessionStorage: FirebaseSessionStorage(defaults: UserDefaults()))
        let exp = expectation(description: "signUp")

        service.signUp(email: "user@example.com", password: "1234") { result in
            if case .failure(let error) = result {
                XCTFail("Expected success, got error: \(error)")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
