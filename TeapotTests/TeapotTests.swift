//
//  TeapotTests.swift
//  TeapotTests
//
//  Created by Igor Ranieri on 26/01/2017.
//  Copyright © 2017 B&B. All rights reserved.
//

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
        var finishCounter = 0

        // pass
        self.teapot?.get("get") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        // fail
        self.teapot?.put("get") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 405)
                XCTAssertNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }

    func testPost() {
        let expectation = self.expectation(description: "Post")
        var finishCounter = 0

        // pass
        self.teapot?.post("post") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        // fail
        self.teapot?.get("post") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 405)
                XCTAssertNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }

    func testPut() {
        let expectation = self.expectation(description: "Put")
        var finishCounter = 0

        // pass
        self.teapot?.put("put") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        self.teapot?.post("put") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 405)
                XCTAssertNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }

    func testDelete() {
        let expectation = self.expectation(description: "Delete")
        var finishCounter = 0

        // pass
        self.teapot?.delete("delete") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 200)
                XCTAssertNotNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        // fail
        self.teapot?.delete("get") { (result) in

            switch result {
            case .success(let json, let response):
                XCTAssertEqual(response.statusCode, 405)
                XCTAssertNil(json)
            case .failure(_, _, _):
                XCTAssertTrue(false)
            }

            XCTAssertNotNil(result)

            finishCounter += 1
            if finishCounter == 2 {
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 5.0) { error in
            if let error = error {
                XCTAssert(false, error.localizedDescription)
            }
        }
    }
}
