import XCTest
@testable import TeapotMac

class BasicAuthTests: XCTestCase {
    let username = "admin"
    let password = "test123"
    let expectedBasicAuth = "Basic YWRtaW46dGVzdDEyMw=="

    lazy var teapot: Teapot = {
        let url = URL(string: "https://test.com")!

        return Teapot(baseURL: url)
    }()

    func testHeaderKey() {
        XCTAssertEqual(self.teapot.basicAuthenticationHeaderKey, "Authorization")
    }

    func testBase64Encoding() {
        let key = self.teapot.basicAuthenticationValue(username: self.username, password: self.password)

        XCTAssertEqual(key, self.expectedBasicAuth)
    }

    func testHeader() {
        guard let header = self.teapot.basicAuthenticationHeader(username: self.username, password: self.password) else {
            XCTFail("Header was nil for username/password combo: \(self.username):\(password)")
            return
        }

        XCTAssertEqual(header, [self.teapot.basicAuthenticationHeaderKey: self.expectedBasicAuth])
    }
}
