//
//  NetworkServiceTests.swift
//  NavigationTests
//
//  Created by Codex on 19.02.2026.
//

import XCTest
@testable import Navigation

final class NetworkServiceTests: XCTestCase {

    private final class NetworkSessionFake: NetworkSessionProtocol {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        func dataTask(with url: URL,
                      completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            completion(data, response, error)
        }
    }

    func testRequest_withSuccess_returnsSuccessResult() {
        let fake = NetworkSessionFake()
        let url = URL(string: "https://example.com")!
        fake.data = "OK".data(using: .utf8)
        fake.response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        fake.error = nil

        let expectation = expectation(description: "Completion called")
        var captured: NetworkServiceResult?

        NetworkService.request(for: .people(url.absoluteString), session: fake) { result in
            captured = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(captured, .success(data: "OK", statusCode: 200))
    }

    func testRequest_withError_returnsFailureResult() {
        let fake = NetworkSessionFake()
        let url = URL(string: "https://example.com")!
        fake.data = nil
        fake.response = nil
        fake.error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "failure"])

        let expectation = expectation(description: "Completion called")
        var captured: NetworkServiceResult?

        NetworkService.request(for: .people(url.absoluteString), session: fake) { result in
            captured = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(captured, .failure("failure"))
    }

    func testRequest_withEmptyData_returnsEmptyResult() {
        let fake = NetworkSessionFake()
        let url = URL(string: "https://example.com")!
        fake.data = nil
        fake.response = nil
        fake.error = nil

        let expectation = expectation(description: "Completion called")
        var captured: NetworkServiceResult?

        NetworkService.request(for: .people(url.absoluteString), session: fake) { result in
            captured = result
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(captured, .empty)
    }
}

