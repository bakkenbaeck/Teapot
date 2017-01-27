import Foundation

/// A light-weight abstraction for URLSession.
open class Teapot {

    public enum TeapotError: Error {
        case invalidRequestPath
        case invalidResponseStatus
    }

    /// The URL request verb to be passed to the URLRequest.
    enum Verb: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    // MARK: - Properties

    open lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "no.bakkenbaeck.NetworkQueue"
        queue.qualityOfService = .userInitiated

        return queue
    }()

    open var configuration = URLSessionConfiguration.default

    open lazy var session: URLSession = {
        let session = URLSession(configuration: self.configuration, delegate: nil, delegateQueue: self.queue)

        return session
    }()

    open var baseURL: URL

    // MARK: - Initialiser

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    // MARK: - API

    /// Perform a GET operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    open func get(_ path: String, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {

        self.execute(verb: .get, path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a POST operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    open func post(_ path: String, parameters: JSON? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {

        self.execute(verb: .post, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a PUT operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    open func put(_ path: String, parameters: JSON? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {

        self.execute(verb: .put, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a DELETE operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    open func delete(_ path: String, parameters: JSON? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {

        self.execute(verb: .delete, path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }
    
    /*
     open func patch() {
     }
     */

    // MARK: - Helper methods

    /// Execute a URLRequest call for the given parameters.
    ///
    /// - Parameters:
    ///   - verb: The HTTP verb: GET/POST/PUT/DELETE, as an enum value.
    ///   - path: The relative path for the API call.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0. See URLRequest doc for more.
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    func execute(verb: Verb, path: String, parameters: JSON? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {
        do {
            let request = try self.request(verb: verb, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular)


            self.runTask(with: request) { (result) in
                switch result {
                case .success(let json, let response):
                    // Handle non-2xx status as error.
                    if response.statusCode < 200 || response.statusCode > 299 {
                        let errorResult = NetworkResult(json, response, TeapotError.invalidResponseStatus)
                        completion(errorResult)
                    } else {
                        completion(result)
                    }
                default:
                    completion(result)
                }
            }
        } catch {
            // Catch exceptions and handle them as errors for the client.
            let response = HTTPURLResponse(url: self.baseURL.appendingPathComponent(path), statusCode: 400, httpVersion: nil, headerFields: headerFields)!
            let result = NetworkResult(nil, response, error)

            completion(result)
        }
    }

    /// Create a URL request for a given set of parameters.
    ///
    /// - Parameters:
    ///   - verb: The HTTP verb: GET/POST/PUT/DELETE, as an enum value.
    ///   - path: The relative path for the API call.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 60.0. See URLRequest doc for more.
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    /// - Returns: URLRequest
    func request(verb: Verb, path: String, parameters: JSON? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true) throws -> URLRequest {
        let components = path.components(separatedBy: "?")
        var urlComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.path = components.first ?? ""
        urlComponents.percentEncodedQuery = components.last ?? ""

        guard let url = urlComponents.url else { throw TeapotError.invalidRequestPath }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: timeoutInterval)
        request.allowsCellularAccess = allowsCellular
        request.httpMethod = verb.rawValue

        if let headerFields = headerFields {
            for headerField in headerFields {
                request.setValue(headerField.value, forHTTPHeaderField: headerField.key)
            }
        }

        if let parameters = parameters {
            request.httpBody = parameters.data
        }

        return request
    }

    func runTask(with request: URLRequest, completion: @escaping((NetworkResult) -> Void)) {
        let task = self.session.dataTask(with: request) { (data, response, error) in
            var json: JSON? = nil

            if let data = data, let deserialised = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let dictionary = deserialised as? [String: Any] {
                    json = JSON(dictionary)
                } else if let array = deserialised as? [[String: Any]] {
                    json = JSON(array)
                }
            }

            DispatchQueue.main.async {
                let result = NetworkResult(json, response as! HTTPURLResponse, error)
                completion(result)
            }
        }

        task.resume()
    }

}

