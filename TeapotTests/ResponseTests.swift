import XCTest
@testable import TeapotMac

class ResponseTests: XCTestCase {
    func testFromArray() {
        let ary: [[String: Any]] = [["test" : 1]]
        let data = try! JSONSerialization.data(withJSONObject: ary, options: [])
        let json = RequestParameter(ary)

        XCTAssertNotNil(json.array)
        XCTAssertNotNil(json.data)
        XCTAssertNil(json.dictionary)
        XCTAssertEqual(json.data, data)
    }

    func testFromDict() {
        let dict: [String: Any] = ["test" : 1]
        let data = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let json = RequestParameter(dict)

        XCTAssertNil(json.array)
        XCTAssertNotNil(json.data)
        XCTAssertNotNil(json.dictionary)
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
        XCTAssertNotNil(json.data)
        XCTAssertNotNil(json.array)
        // internal data uses [] for dicts as well as arrays, so:
        XCTAssertNotEqual(json.data, data)
        // but length should still match
        XCTAssertEqual(json.data?.count, data.count)
    }
}
