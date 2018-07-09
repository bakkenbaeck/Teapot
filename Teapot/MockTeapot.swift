import Foundation

/// A subclass of Teapot to be used for mocking
open class MockTeapot: Teapot {
    /// The status codes in words to be set as status code
    public enum StatusCode: Int {
        case ok = 200
        case noContent = 204
        case created = 201
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case internalServerError = 500
        case serviceUnavailable = 503
    }

    private let currentBundle: Bundle
    private let mockFilename: String
    private let statusCode: StatusCode

    private var endpointsToOverride = [String: String]()

    private var headersToCheckFor = [String: String]()

    /// Initialiser.
    ///
    /// - Parameters:
    ///   - bundle: the bundle of your test target, where it will search for the mock file
    ///   - mockFileName: the name of the mock file containing the json that will be returned
    ///   - statusCode: the status code for the response to return errors. Default is 200 "ok" 👌
    public init(bundle: Bundle, mockFilename: String, statusCode: StatusCode = .ok) {
        self.currentBundle = bundle
        self.mockFilename = mockFilename
        self.statusCode = statusCode

        super.init(baseURL: URL(string: "https://mock.base.url.com")!)
    }

    /// Sets the filename of the mocked json you want to return for a call to a certain endpoint
    /// For example, when you have a security call to the server that get's called every time you do an API call
    ///
    /// NOTE: This will ignore this instance's `statusCode` if the overridden endpoint is not the primary target of the call
    ///       (ie, is not the GET/PUT/POST etc path). When you make that underlying security call, the call to this endpoint
    ///       will still return as if all is well, but the main call will fail with this Teapot's `statusCode`. This allows
    ///       better testing of failure handling for endpoints which require prerequisite calls.
    ///
    /// - Parameters:
    ///   - endPoint: the last path component of the endpoint which needs to get overridden
    ///   - filename: the name of the json file from which you want the data to be returned
    public func overrideEndPoint(_ endPoint: String, withFilename filename: String) {
        self.endpointsToOverride[endPoint] = filename
    }

    /// Sets up a set of headers to check for the presence of.
    /// Other headers can be present, but these are the ones which must be present.
    ///
    /// - Parameter expectedHeaders: The headers to check for
    public func setExpectedHeaders(_ expectedHeaders: [String: String]) {
        self.headersToCheckFor = expectedHeaders
    }

    /// Removes any expected headers to check for.
    /// Should be called after each test.
    public func clearExpectedHeaders() {
        self.headersToCheckFor.removeAll()
    }

    /// Checks to see if there's an overridden endpoint file for a given path
    ///
    /// - Parameter path: The full path to check for a file for its endpoint
    /// - Returns: [Optional] The filename of the file, or nil if there is no stored file
    private func endpointFileNameForPath(_ path: String) -> String? {
        let endPoint = (path as NSString).lastPathComponent
        return self.endpointsToOverride[endPoint]
    }

    override func execute(verb: Teapot.Verb, path: String, parameters: RequestParameter?, headerFields: [String: String]?, timeoutInterval: TimeInterval, allowsCellular: Bool, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        guard self.checkHeadersAgainstExpected(headers: headerFields, for: path) else {
            let errorResult = NetworkResult(nil, HTTPURLResponse(url: URL(string: path)!, statusCode: 400, httpVersion: nil, headerFields: nil)!, TeapotError.incorrectHeaders(expected: headersToCheckFor, received: headerFields))
            completion(errorResult)
            return nil
        }

        self.getMockedData(forPath: path) { json, error in
            var mockedError = error
            let response = HTTPURLResponse(url: URL(string: path)!, statusCode: self.statusCode.rawValue, httpVersion: nil, headerFields: nil)
            let requestParameter = json != nil ? RequestParameter(json!) : nil

            if self.statusCode.rawValue >= 300 && self.endpointFileNameForPath(path) == nil {
                mockedError = TeapotError.invalidResponseStatus(self.statusCode.rawValue)
            }

            let networkResult = NetworkResult(requestParameter, response!, mockedError)

            completion(networkResult)
        }

        return nil // there's no real request happening.
    }

    private func getMockedData(forPath path: String, completion: @escaping (([String: Any]?, TeapotError?) -> Void)) {
        let resource = self.endpointFileNameForPath(path) ?? self.mockFilename

        if let url = currentBundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, TeapotError.invalidMockFile(resource))
                }
            } catch {
                completion(nil, TeapotError.invalidMockFile(resource))
            }
        } else {
            completion(nil, TeapotError.missingMockFile(resource))
        }
    }

    private func checkHeadersAgainstExpected(headers: [String: String]?, for path: String) -> Bool {
        guard self.endpointFileNameForPath(path) == nil else {
            // Don't check headers on overridden endpoints
            return true
        }

        guard !self.headersToCheckFor.isEmpty else {
            // nothing to check
            return true
        }

        guard let receivedHeaders = headers else {
            // We want to check, but nothing was received
            return false
        }

        for (key, value) in self.headersToCheckFor {
            let receivedValue = receivedHeaders[key]
            if receivedValue != value {
                return false
            }
        }

        // If you've gotten here, all the keys you want are present.
        return true
    }
}
