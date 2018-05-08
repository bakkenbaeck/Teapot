import XCTest
@testable import TeapotMac

class TeapotTests: XCTestCase {

    var teapot: Teapot?

    override func setUp() {
        super.setUp()

        self.teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)
    }
    
    override func tearDown() {
        self.teapot = nil
        super.tearDown()
    }
    
    func testGet() {
        let expectation = self.expectation(description: "Get")

        self.teapot?.get("/get") { (result: NetworkResult) in
            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPost() {
        let expectation = self.expectation(description: "Post")

        self.teapot?.post("/post") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPostWithJSONData() {
        let expectation = self.expectation(description: "Put with JSON")

        let array = "[{\"foo\":\"bar\"},{\"foo\":\"baz\"}]"
        guard let jsonData = array.data(using: .utf8) else {
            XCTFail("Couldn't encode array string")
            return
        }

        let param = RequestParameter(jsonData)

        self.teapot?.post("/post", parameters: param) { (result) in
            defer {
                expectation.fulfill()
            }

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)

                guard let returnedData = json else {
                    XCTFail("No data returned")
                    return
                }

                guard let dictionary = returnedData.dictionary else {
                    XCTFail("Returned data not of expected type")
                    return
                }

                // Did HTTPBin get the data we sent in the same format we sent it?
                guard
                    let sentBackData = dictionary["data"] as? String,
                    let encodedSentBack = sentBackData.data(using: .utf8) else {
                        XCTFail("Sent back data not of expected type")
                        return
                }

                XCTAssertEqual(encodedSentBack, jsonData)

                // Did we send this with the appropriate header type?
                guard let sentHeaders = dictionary["headers"] as? [String: Any] else {
                    XCTFail("HTTPBin did not send back a copy of the headers it recieved")
                    return
                }

                XCTAssertEqual(sentHeaders["Content-Type"] as? String, "application/json")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPut() {
        let expectation = self.expectation(description: "Put")

        self.teapot?.put("/put") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testPutWithJSONData() {
        let expectation = self.expectation(description: "Put with JSON")

        let dict = "{\"foo\":\"bar\"}"
        guard let jsonData = dict.data(using: .utf8) else {
            XCTFail("Couldn't encode dictionary string")
            return
        }

        let param = RequestParameter(jsonData)

        self.teapot?.put("/put", parameters: param) { (result) in
            defer {
                expectation.fulfill()
            }

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)

                guard let returnedData = json else {
                    XCTFail("No data returned")
                    return
                }

                guard let dictionary = returnedData.dictionary else {
                    XCTFail("Returned data not of expected type")
                    return
                }

                // Did HTTPBin get the data we sent in the same format we sent it?
                guard
                    let sentBackData = dictionary["data"] as? String,
                    let encodedSentBack = sentBackData.data(using: .utf8) else {
                    XCTFail("Sent back data not of expected type")
                    return
                }

                XCTAssertEqual(encodedSentBack, jsonData)

                // Did we send this with the appropriate header type?
                guard let sentHeaders = dictionary["headers"] as? [String: Any] else {
                    XCTFail("HTTPBin did not send back a copy of the headers it recieved")
                    return
                }

                XCTAssertEqual(sentHeaders["Content-Type"] as? String, "application/json")
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)
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
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testQuery() {
        let expectation = self.expectation(description: "Query")
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
            case .failure(_, _, let error):
                XCTFail("Unexpected error: \(error)")
            }

            XCTAssertNotNil(result)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testImage() {
        let expectation = self.expectation(description: "GetImage")
        let url = URL(string: "http://icons.iconarchive.com/icons/martz90/circle/512/app-draw-icon.png")!

        Teapot(baseURL: url).get() { (result: NetworkImageResult) in
            switch result {
            case .success(let image, let response):
                guard
                    let localImage = Bundle(for: TeapotTests.self).image(forResource: NSImage.Name(rawValue: "app-draw-icon")),
                    let tiff = localImage.tiffRepresentation else {
                        XCTFail("Could not create local image TIFF")
                        expectation.fulfill()
                        return
                }

                XCTAssertEqual(response.statusCode, 200)
                XCTAssertEqual(image.tiffRepresentation, tiff)
                expectation.fulfill()
            case .failure(_, let error):
                XCTFail("Unexpected error: \(error)")
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testCancelRequest() {
        let invertedExpecation = expectation(description: "Request completed")
        invertedExpecation.isInverted = true

        guard let task = self.teapot?.get("/get", completion: { (result: NetworkResult) in
            // This should not happen, so we fulfill the inverted expectation
            invertedExpecation.fulfill()
        }) else {
            XCTFail("Could not create task")
            return
        }

        task.cancel()

        // Here, we wait a tiny bit to make sure the inverted expectation is *not* fulfilled
        self.waitForExpectations(timeout: 0.5, handler: nil)

        // Then we check the cancellation state.
        switch task.state {
        case .canceling:
            // Still in the process of cancelling, but is at least defintiely cancelling.
            break
        case .completed:
            guard let error = task.error else {
                XCTFail("A cancelled task should have an error if it hits completed!")
                return
            }

            XCTAssertEqual((error as NSError).code, NSURLErrorCancelled)
        case .running:
            XCTFail("Cancelled task is still running!")
        case .suspended:
            XCTFail("Cancelled task is only suspended!")
        }
    }
}
