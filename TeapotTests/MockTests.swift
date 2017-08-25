import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {

    func testMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self))
        mockedTeapot.get("/get") { (result: NetworkResult) in
            switch result {            
            case .success(let json, let response):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
            case .failure:
                XCTFail()
            }
        }
    }

    func testMissingMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self))
        mockedTeapot.get("/missing") { (result: NetworkResult) in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error {
                    case MockTeapot.MockError.missingMockFile(let fileName):
                        XCTAssertEqual(fileName, "missing.json")
                    default:
                        XCTFail()
                }
            }
        }
    }

    func testInvalidMock() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self))
        mockedTeapot.get("/invalid") { (result: NetworkResult) in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, _, let error):
                switch error {
                case MockTeapot.MockError.invalidMockFile(let fileName):
                    XCTAssertEqual(fileName, "error: The data couldn’t be read because it isn’t in the correct format. In file: 'invalid.json'")
                default:
                    XCTFail()
                }
            }
        }
    }

    func testNoContent() {
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), statusCode: .noContent)
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
        let mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self), statusCode: .unauthorized)
        mockedTeapot.get("/get") { (result: NetworkResult) in
            switch result {
            case .success:
                XCTFail()
            case .failure(_, let response, _):
                XCTAssertEqual(response.statusCode, 401)
            }
        }
    }
}
