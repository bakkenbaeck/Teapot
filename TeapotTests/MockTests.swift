import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {
    var mockedTeapot: MockTeapot?
    
    override func setUp() {
        super.setUp()

        mockedTeapot = MockTeapot(baseURL: URL(string: "https://some.base.url.com")!)
    }

    func testMock() {
        let expectation = self.expectation(description: "Mocked get")

        mockedTeapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(json!.dictionary!["key"] as! String, "value")
            case .failure(_, _, let error):
                print(error)
                XCTFail()
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10.0)
    }
}