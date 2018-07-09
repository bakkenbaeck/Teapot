@testable import TeapotMac
import XCTest

class MockTests: XCTestCase {
    func testMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        mockedTeapot.get("/get") { result in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure(_, _, let error):
                XCTFail("Unexpected error getting mock: \(error)")
            }
        }
    }

    func testMissingMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "missing")

        mockedTeapot.get("/missing") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error.type {
                case .missingMockFile:
                    XCTAssertEqual(error.description, "An error occurred: expected mockfile with name: missing.json")
                default:
                    XCTFail("Incorrect error for missing mock: \(error)")
                }
            }
        }
    }

    func testInvalidMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "invalid")

        mockedTeapot.get("/invalid") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error.type {
                case .invalidMockFile:
                    XCTAssertEqual(error.description, "An error occurred: invalid mockfile with name: invalid.json")
                default:
                    XCTFail("Incorrect error for invalid file: \(error)")
                }
            }
        }
    }

    func testNoContent() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get", statusCode: .noContent)
        mockedTeapot.get("/get") { result in
            switch result {
            case .success(_, let response):
                XCTAssertEqual(response.statusCode, 204)
            case .failure:
                XCTFail("Incorrect status code returned for no content")
            }
        }
    }

    func testUnauthorizedError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get", statusCode: .unauthorized)

        mockedTeapot.get("/get") { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, let response, _):
                XCTAssertEqual(response.statusCode, 401)
            }
        }
    }

    func testEndPointOverriding() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")
        mockedTeapot.overrideEndPoint("overridden", withFilename: "overridden")

        mockedTeapot.get("/overridden") { result in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["overridden"] as? String, "value")
            case .failure(let error):
                XCTFail("Unexpected error overriding endpoint: \(error)")
            }
        }
    }

    func testEndpointOverriddingThenHittingOtherEndpointWithError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "", statusCode: .internalServerError)
        mockedTeapot.overrideEndPoint("overridden", withFilename: "overridden")

        mockedTeapot.get("/overridden") { initialResult in
            switch initialResult {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["overridden"] as? String, "value")
                mockedTeapot.get("/get") { secondaryResult in
                    switch secondaryResult {
                    case .success:
                        XCTFail("That should not have worked")
                    case .failure(_, _, let error):
                        print(error)
                        XCTAssertEqual(error.responseStatus, 500)
                    }
                }
            case .failure:
                XCTFail("The overridden endpoint should have worked")
            }
        }
    }

    func testCheckingForHeadersWhichAreThereSucceeds() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get", headerFields: expectedHeaders) { result in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testCheckingForHeadersWhichAreNotThereReturnsError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get") { result in
            switch result {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error, TeapotError.incorrectHeaders(expected: expectedHeaders, received: nil))
            }
        }
    }

    func testCheckingForPartialHeadersReturnsError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        let wrongHeaders = ["foo": "bar"]
        mockedTeapot.get("/get", headerFields: wrongHeaders) { result in
            switch result {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error, TeapotError.incorrectHeaders(expected: expectedHeaders, received: wrongHeaders))
            }
        }
    }

    func testPassingExtraHeadersSucceeds() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        var headersToPass = expectedHeaders
        headersToPass["extra"] = "lol"

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get", headerFields: headersToPass) { result in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testClearingHeadersWorks() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        let wrongHeaders = ["foo": "bar"]
        mockedTeapot.get("/get", headerFields: wrongHeaders) { wrongHeaderResult in
            switch wrongHeaderResult {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error, TeapotError.incorrectHeaders(expected: expectedHeaders, received: wrongHeaders))
            }
        }

        mockedTeapot.clearExpectedHeaders()

        mockedTeapot.get("/get") { clearedHeaderResult in
            switch clearedHeaderResult {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testExpectedHeadersAreNotCheckedForEndpointOverrideButAreForMainRequest() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2"
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        // If you don't pass the expected headers to the overridden endpoint but do
        // pass them to the final endpoint, this should succeed.
        mockedTeapot.overrideEndPoint("overridden", withFilename: "overridden")

        mockedTeapot.get("/overridden") { firstOverriddenResult in
            switch firstOverriddenResult {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["overridden"] as? String, "value")
                mockedTeapot.get("/get", headerFields: expectedHeaders) { firstGetResult in
                    switch firstGetResult {
                    case .success(let json, _):
                        XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
                    case .failure(_, _, let error):
                        XCTFail("Unexpected error hitting primary endpoint: \(error)")
                    }
                }
            case .failure(_, _, let error):
                XCTFail("Unexpected error hitting overridden endpoint: \(error)")
            }
        }

        // If you don't pass the expected headers to the overridden getter OR to the main get method, then this should fail.
        mockedTeapot.get("/overridden") { secondOverriddenResult in
            switch secondOverriddenResult {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["overridden"] as? String, "value")
                mockedTeapot.get("/get") { secondGetResult in
                    switch secondGetResult {
                    case .success:
                        XCTFail("Unexpected success when not passing correct headers!")
                    case .failure(_, _, let error):
                        XCTAssertEqual(error, TeapotError.incorrectHeaders(expected: expectedHeaders, received: nil))
                    }
                }
            case .failure(_, _, let error):
                XCTFail("Unexpected error hitting overridden endpoint: \(error)")
            }
        }
    }
}
