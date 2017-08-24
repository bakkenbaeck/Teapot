import Foundation

/// A subclass of Teapot to be used for mocking
open class MockTeapot: Teapot {

    private var currentBundle: Bundle

    /// The status codes in words to be set as status code
    public enum StatusCode: Int {
        case ok = 200
        case created = 201
        case unauthorized = 401
        case forbidden = 403
        case notFound = 404
        case internalServerError = 500
        case serviceUnavailable = 503
    }

    /// Errors specific to parsing the specified mock file
    public enum MockError: Error {
        case missingMockFile(String)
        case invalidMockFile(String)
    }

    /// The status code the URL request should return
    private let statusCode: StatusCode

    /// Initialiser.
    ///
    /// - Parameters:
    ///   - bundle: the bundle of your test target. When you add a json file with the name of the endpoint to your test target it will return this data.
    public init(bundle: Bundle, statusCode: StatusCode = .ok) {
        self.currentBundle = bundle
        self.statusCode = statusCode

        super.init(baseURL: URL(string: "https://mock.base.url.com")!)
    }

    override func execute(verb _: Verb, path: String, parameters _: RequestParameter? = nil, headerFields _: [String: String]? = nil, timeoutInterval _: TimeInterval = 5.0, allowsCellular _: Bool = true, completion: @escaping ((NetworkResult) -> Void)) {
        self.getMockedData(forPath: path) { json, error in
            var mockedError = error
            let response = HTTPURLResponse(url: URL(string: path)!, statusCode: self.statusCode.rawValue, httpVersion: nil, headerFields: nil)
            let requestParameter = json != nil ? RequestParameter(json!) : nil

            if self.statusCode != .ok {
                mockedError = TeapotError.invalidResponseStatus
            }
            let networkResult = NetworkResult(requestParameter, response!, mockedError)

            completion(networkResult)
        }
    }

    func getMockedData(forPath path: String, completion: @escaping (([String: Any]?, Error?) -> Void)) {
        let resource = (path as NSString).lastPathComponent

        if let url = currentBundle.url(forResource: resource, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, MockError.invalidMockFile("\(resource).json"))
                }
            } catch let error {
                completion(nil, MockError.invalidMockFile("error: \(error.localizedDescription) In file: '\(resource).json'"))
            }
        } else {
            completion(nil, MockError.missingMockFile("\(resource).json"))
        }
    }
}
