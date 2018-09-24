//
//  DeliveryQueueTests.swift
//  TeapotMac
//
//  Created by Igor Ranieri on 21.09.18.
//  Copyright © 2018 B&B. All rights reserved.
//

@testable import TeapotMac
import XCTest

class DeliveryQueueTests: XCTestCase {

    func testDeliveryOnQueueGet() {
        let expectation = self.expectation(description: "Get")

        let dispatchQueue = DispatchQueue(label: "dispatch.queue.here")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!,
                            deliveryQueue: dispatchQueue)

        teapot.get("/get") { result in
            XCTAssertTrue(!Thread.isMainThread)
            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!

            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryOnQueuePost() {
        let expectation = self.expectation(description: "Post")

        let dispatchQueue = DispatchQueue(label: "dispatch.queue.here")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!,
                            deliveryQueue: dispatchQueue)

        teapot.post("/post") { result in
            XCTAssertTrue(!Thread.isMainThread)
            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!

            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

       self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryOnQueuePut() {
        let expectation = self.expectation(description: "Put")

        let dispatchQueue = DispatchQueue(label: "dispatch.queue.here")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!,
                            deliveryQueue: dispatchQueue)

        teapot.put("/put") { result in
            XCTAssertTrue(!Thread.isMainThread)
            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!

            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryOnQueueDelete() {
        let expectation = self.expectation(description: "Delete")

        let dispatchQueue = DispatchQueue(label: "dispatch.queue.here")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!,
                            deliveryQueue: dispatchQueue)

        teapot.delete("/delete") { result in
            XCTAssertTrue(!Thread.isMainThread)
            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!

            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryOnQueueImage() {
        let expectation = self.expectation(description: "Image")

        let dispatchQueue = DispatchQueue(label: "dispatch.queue.here")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!,
                            deliveryQueue: dispatchQueue)

        teapot.downloadImage { result in
            XCTAssertTrue(!Thread.isMainThread)

            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }
    
    func testDeliveryOnMain() {
        let expectation = self.expectation(description: "Get")

        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)

        teapot.get("/get") { result in
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryQueueOverrideGet() {
        let expectation = self.expectation(description: "Override Get")
        let dispatchQueue = DispatchQueue(label: "dispatch.queue.overriden")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)

        teapot.get("/get", deliveryQueue: dispatchQueue) { result in
            XCTAssertTrue(!Thread.isMainThread)

            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryQueueOverridePost() {
        let expectation = self.expectation(description: "Override Post")
        let dispatchQueue = DispatchQueue(label: "dispatch.queue.overriden")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)

        teapot.post("/post", deliveryQueue: dispatchQueue) { result in
            XCTAssertTrue(!Thread.isMainThread)

            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryQueueOverridePut() {
        let expectation = self.expectation(description: "Override Put")
        let dispatchQueue = DispatchQueue(label: "dispatch.queue.overriden")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)

        teapot.put("/put", deliveryQueue: dispatchQueue) { result in
            XCTAssertTrue(!Thread.isMainThread)

            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }

    func testDeliveryQueueOverrideDelete() {
        let expectation = self.expectation(description: "Override Delete")
        let dispatchQueue = DispatchQueue(label: "dispatch.queue.overriden")
        let teapot = Teapot(baseURL: URL(string: "https://httpbin.org")!)

        teapot.delete("/delete", deliveryQueue: dispatchQueue) { result in
            XCTAssertTrue(!Thread.isMainThread)

            let queueLabel = String(cString: __dispatch_queue_get_label(nil), encoding: .utf8)!
            XCTAssertEqual(dispatchQueue.label, queueLabel)

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 20.0)
    }
}
