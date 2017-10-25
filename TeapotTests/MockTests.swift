import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {

    func testMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), mockFilename: "get")

        mockedTeapot.get("/get") { (result: NetworkResult) in
            switch result {            
            case .success(let json, _):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
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
                        XCTAssertEqual(error.errorDescription, "An error occurred: expected mockfile with name: missing.json")
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
                    XCTAssertEqual(error.errorDescription, "An error occurred: invalid mockfile with name: invalid.json")
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
                XCTAssertEqual(json!.dictionary!["overridden"] as! String, "value")
            case .failure(let error):
                print(error)
                XCTFail()
            }
        }
    }
}
