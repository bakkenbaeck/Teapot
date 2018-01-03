import XCTest
@testable import TeapotMac

class TeapotTests: XCTestCase {

    var teapot: Teapot?

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.teapot = nil
        super.tearDown()
    }
    
    func testGet() {
        let expectation = self.expectation(description: "Get")

        // pass
        self.teapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPost() {
        let expectation = self.expectation(description: "Post")

        // pass
        self.teapot?.post("/post") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPut() {
        let expectation = self.expectation(description: "Put")

        // pass
        self.teapot?.put("/put") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDelete() {
        let expectation = self.expectation(description: "Delete")

        // pass
        self.teapot?.delete("/delete") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testQuery() {
        let expectation = self.expectation(description: "Delete")
        self.teapot?.get("/get/?query=\("something")") { (result: NetworkResult) in

            switch result {
            case .success(_, _):
                break
            case .failure(_, let response, _):
                XCTAssertEqual(response.statusCode, 404)
            }

            XCTAssertNotNil(result)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testEscapedQuery() {
        let expectation = self.expectation(description: "EscapedQuery")
        self.teapot?.get("/get?query=hello%26%26world&world") { (result: NetworkResult) in

            switch result {
            case .success(let json, _):
                if let json = json?.dictionary, let queryResult = ((json["args"] as? [String: Any])?["query"]) as? String {
                    XCTAssertEqual(queryResult, "hello&&world")
                }
                break
            case .failure:
                XCTFail()
            }

            XCTAssertNotNil(result)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testImage() {
        // http://icons.iconarchive.com 
        // /icons/martz90/circle/512/app-draw-icon.png
        let expectation = self.expectation(description: "GetImage")
        let url = URL(string: "http://icons.iconarchive.com/icons/martz90/circle/512/app-draw-icon.png")!

        Teapot(baseURL: url).get() { (result: NetworkImageResult) in
            switch result {
            case .success(let image, let response):
                guard let localImage = Bundle(for: TeapotTests.self).image(forResource: NSImage.Name(rawValue: "app-draw-icon")), let tiff = localImage.tiffRepresentation else {
                    XCTFail("Could not create local image TIFF")
                    expectation.fulfill()
                    return
                }

                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(image.tiffRepresentation, tiff)
                expectation.fulfill()
            case .failure(_, _):
                XCTFail("Network call for image failed")
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 20.0)
    }
}
