import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {
    var mockedTeapot: MockTeapot?

    override func setUp() {
        super.setUp()

        self.mockedTeapot = MockTeapot(bundle: Bundle(for: MockTests.self))
    }

    func testMock() {
        self.mockedTeapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
            case .failure:
                XCTFail()
            }
        }
    }

    func testMissingMock() {
        self.mockedTeapot?.get("/missing") { (result: NetworkResult) in
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
        self.mockedTeapot?.get("/invalid") { (result: NetworkResult) in
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
}
