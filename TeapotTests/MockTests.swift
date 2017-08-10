import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {
    var mockedTeapot: MockTeapot?

    override func setUp() {
        super.setUp()

        mockedTeapot = MockTeapot(baseURL: URL(string: "https://some.base.url.com")!, bundle: Bundle(for: MockTests.self))
    }

    func testMock() {
        mockedTeapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
            case .failure:
                XCTFail()
            }
        }
    }

    func testMissingMock() {
        mockedTeapot?.get("/missing") { (result: NetworkResult) in
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
}
