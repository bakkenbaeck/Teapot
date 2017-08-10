import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {
    var mockedTeapot: MockTeapot?

    override func setUp() {
        super.setUp()

        mockedTeapot = MockTeapot(baseURL: URL(string: "https://some.base.url.com")!, bundle: Bundle(for: MockTests.self))
    }

    func testMock() {
        let expectation = self.expectation(description: "Mocked get.json")

        mockedTeapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
            case .failure:
                XCTFail()
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10.0)
    }

    func testMissingMock() {
        let expectation = self.expectation(description: "Test missing mockfile error")

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

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10.0)
    }
}
