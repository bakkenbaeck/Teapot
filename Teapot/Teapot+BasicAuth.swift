import Foundation

public extension Teapot {
    /// The basic authentication header key value. Use this as the key in your headerFields dictionary.
    public var basicAuthenticationHeaderKey: String {
        return "Authorization"
    }


    /// Converts a username, password pair into a basic authentication string.
    ///
    /// - Example: "Basic 0xfa0123456789086421af"
    /// - Returns a string or `nil` if we can't covert the combined string to an octet data.
    ///
    /// - Parameters:
    ///   - username: the basic auth username
    ///   - password: the basic auth password
    /// - Returns: basic authentication string with the format "Basic hexValue".
    public func basicAuthenticationValue(username: String, password: String) -> String? {
        let authString = "\(username):\(password)"
        guard let octetString = authString.data(using: .utf8) else { return nil }
        let encodedString = octetString.base64EncodedString()

        return "Basic \(encodedString)"
    }

    /// Converts a username, password pair into a complete basic auth header.
    ///
    /// - Example: ["Authorization": "Basic 0xfa0123456789086421af"
    /// - Returns nil if we can't convert the string to an octet data.
    ///
    /// - Parameters:
    ///   - username: the basic auth username
    ///   - password: the basic auth password
    /// - Returns: bais authentication header dictionary or nil.
    public func basicAuthenticationHeader(username: String, password: String) -> [String: String]? {
        let authString = "\(username):\(password)"
        guard let octetString = authString.data(using: .utf8) else { return nil }
        let encodedString = octetString.base64EncodedString()

        return [self.basicAuthenticationHeaderKey: "Basic \(encodedString)"]
    }
}
