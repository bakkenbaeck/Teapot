import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {

    func testMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        mockedTeapot.get("/get") { (result: NetworkResult) in
            switch result {            
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure:
                XCTFail()
            }
        }
    }

    func testMissingMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "missing")

        mockedTeapot.get("/missing") { (result: NetworkResult) in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error.type {
                    case .missingMockFile:
                        XCTAssertEqual(error.description, "An error occurred: expected mockfile with name: missing.json")
                    default:
                        XCTFail()
                }
            }
        }
    }

    func testInvalidMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "invalid")

        mockedTeapot.get("/invalid") { (result: NetworkResult) in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error.type {
                case .invalidMockFile:
                    XCTAssertEqual(error.description, "An error occurred: invalid mockfile with name: invalid.json")
                default:
                    XCTFail()
                }
            }
        }
    }

    func testNoContent() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get", statusCode: .noContent)
        mockedTeapot.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(_, let response):
                XCTAssertEqual(response.statusCode, 204)
            case .failure:
                XCTFail()
            }
        }
    }

    func testUnauthorizedError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get", statusCode: .unauthorized)
        
        mockedTeapot.get("/get") { (result: NetworkResult) in
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

        mockedTeapot.get("/overridden") { (result: NetworkResult) in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["overridden"] as? String, "value")
            case .failure(let error):
                print(error)
                XCTFail()
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
            "baz": "foo2",
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
            "baz": "foo2",
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get") { result in
            switch result {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error.type, .incorrectHeaders)
            }
        }
    }

    func testCheckingForPartialHeadersReturnsError() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2",
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get", headerFields: [ "foo" : "bar" ]) { result in
            switch result {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error.type, .incorrectHeaders)
            }
        }
    }

    func testPassingExtraHeadersSucceeds() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        let expectedHeaders = [
            "foo": "bar",
            "baz": "foo2",
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
            "baz": "foo2",
        ]

        mockedTeapot.setExpectedHeaders(expectedHeaders)

        mockedTeapot.get("/get", headerFields: [ "foo" : "bar" ]) { result in
            switch result {
            case .success:
                XCTFail("Request suceceeded which should not have!")
            case .failure(_, let response, let error):
                XCTAssertEqual(response.statusCode, 400)
                XCTAssertEqual(error.type, .incorrectHeaders)
            }
        }

        mockedTeapot.clearExpectedHeaders()

        mockedTeapot.get("/get") { result in
            switch result {
            case .success(let json, _):
                XCTAssertEqual(json?.dictionary?["key"] as? String, "value")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}
