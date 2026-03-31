import XCTest
@testable import Navigation

final class CheckerServiceTests: XCTestCase {
    func testCheckCredentials_whenEmailAndPasswordAreNotEmpty_returnsSuccess() {
        let service = CheckerService()
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
        let service = CheckerService()
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
        let service = CheckerService()
        let exp = expectation(description: "checkCredentials")

        service.checkCredentials(email: "user@example.com", password: "") { result in
            if case .success = result {
                XCTFail("Expected failure")
            }
            exp.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testSignUp_alwaysReturnsSuccess() {
        let service = CheckerService()
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
