@testable import TeapotMac
import XCTest

class ResponseTests: XCTestCase {
    func testFromArray() {
        let array: [[String: Any]] = [["test": 1]]
        let data = try! JSONSerialization.data(withJSONObject: array, options: [])
        let json = RequestParameter(array)

        XCTAssertNil(json.dictionary)
        XCTAssertNotNil(json.array)
        XCTAssertEqual(json.array?.count, 1)
        XCTAssertNotNil(json.data)
        XCTAssertEqual(json.data, data)
    }

    func testFromDict() {
        let dict: [String: Any] = ["test": 1]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let json = RequestParameter(dict)

        XCTAssertNil(json.array)
        XCTAssertNotNil(json.dictionary)
        XCTAssertEqual(json.dictionary?["test"] as? Int, 1)

        XCTAssertNotNil(json.data)
        XCTAssertEqual(json.data, data)
    }

    func testDictFromData() {
        let data = "{\"employees\":{\"employee\":[{\"id\":\"1\",\"firstName\":\"Tom\",\"lastName\":\"Cruise\"}]}}".data(using: .utf8)!
        let json = RequestParameter(data)

        XCTAssertNil(json.array)
        XCTAssertNotNil(json.data)
        XCTAssertNotNil(json.dictionary)
        XCTAssertEqual(json.data, data)
    }

    func testArrayFromData() {
        let data = "[{\"id\":\"1\",\"firstName\":\"Tom\",\"lastName\":\"Cruise\"}]".data(using: .utf8)!
        let json = RequestParameter(data)

        XCTAssertNil(json.dictionary)

        XCTAssertNotNil(json.array)
        XCTAssertEqual(json.array?.count, 1)

        XCTAssertNotNil(json.data)
        XCTAssertEqual(json.data, data)
    }
}
