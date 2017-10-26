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

    /// overrideEndPoint.
    /// set the filename of the mocked json you want to return for a call to a certain endpoint
    /// for example when you have a security call to the server that get's called every time you do an APICall
    ///
    /// - Parameters:
    ///   - endPoint: the endpoint that needs to get overridden
    ///   - filename: the name of the json file from which you want the data to be returned
    public func overrideEndPoint(_ endPoint: String, withFilename filename: String) {
        self.endpointsToOverride[endPoint] = filename
    }

    override func execute(verb _: Verb, path: String, parameters _: RequestParameter? = nil, headerFields _: [String: String]? = nil, timeoutInterval _: TimeInterval = 5.0, allowsCellular _: Bool = true, completion: @escaping ((NetworkResult) -> Void)) {
        self.getMockedData(forPath: path) { json, error in
            var mockedError = error
            let response = HTTPURLResponse(url: URL(string: path)!, statusCode: self.statusCode.rawValue, httpVersion: nil, headerFields: nil)
            let requestParameter = json != nil ? RequestParameter(json!) : nil

            if self.statusCode.rawValue >= 300 {
                mockedError = TeapotError.invalidResponseStatus(self.statusCode.rawValue)
            }

            let networkResult = NetworkResult(requestParameter, response!, mockedError)

            completion(networkResult)
        }
    }

    func getMockedData(forPath path: String, completion: @escaping (([String: Any]?, TeapotError?) -> Void)) {
        let endPoint = (path as NSString).lastPathComponent
        let resource = self.endpointsToOverride[endPoint] ?? self.mockFilename

        if let url = currentBundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, TeapotError.invalidMockFile(resource))
                }
            } catch let error {
                completion(nil, TeapotError.invalidMockFile(resource))
            }
        } else {
            completion(nil, TeapotError.missingMockFile(resource))
        }
    }
}
