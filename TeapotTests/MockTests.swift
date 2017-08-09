import XCTest
@testable import TeapotMac

class MockTests: XCTestCase {
    let session = MockURLSession()
    let mockedTeapot: Teapot?
    
    override func setUp() {
        super.setUp()

        let mockTeapot = Teapot(baseURL: URL(string: "https://some.base.url.com")!)
        mockedTeapot = Teapot
    }

    func testMock() {
        let expectation = self.expectation(description: "Mocked get")

        mockedTeapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(json, "mocked json")
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 10.0)
    }
}