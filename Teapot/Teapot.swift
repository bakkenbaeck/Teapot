import Foundation

/// A light-weight abstraction for URLSession.
open class Teapot {
    public static var localizationBundle = Bundle(for: Teapot.self)

    /// The URL request verb to be passed to the URLRequest.
    enum Verb: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    // MARK: - Properties

    open lazy var runTaskQueue: DispatchQueue = {
        DispatchQueue(label: "com.backkenbaeck.Teapot.RunTaskQueue", qos: .background)
    }()

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

    open var logger = Logger()

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
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes, always on main queue.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    @discardableResult open func get(_ path: String, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        return self.execute(verb: .get, path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a POST operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes, always on main queue.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    @discardableResult open func post(_ path: String, parameters: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        return self.execute(verb: .post, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a PUT operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes, always on main queue.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    @discardableResult open func put(_ path: String, parameters: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        return self.execute(verb: .put, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }

    /// Perform a DELETE operation.
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call. Appended to the baseURL.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    @discardableResult open func delete(_ path: String, parameters _: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        return self.execute(verb: .delete, path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
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
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0. See URLRequest doc for more.
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkResult once the request completes, always on main queue.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    func execute(verb: Verb, path: String, parameters: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask? {
        do {
            let request = try self.request(verb: verb, path: path, parameters: parameters, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular)

            let task = self.runTask(with: request) { (result: NetworkResult) in
                switch result {
                case .success(let json, let response):
                    // Handle non-2xx status as error.
                    if response.statusCode < 200 || response.statusCode > 299 {
                        let errorResult = NetworkResult(json, response, TeapotError.invalidResponseStatus(response.statusCode))
                        completion(errorResult)
                    } else {
                        completion(result)
                    }
                default:
                    completion(result)
                }
            }

            return task
        } catch {
            // Catch exceptions and handle them as errors for the client.
            let response = HTTPURLResponse(url: self.baseURL.appendingPathComponent(path), statusCode: 400, httpVersion: nil, headerFields: headerFields)!
            let result = NetworkResult(nil, response, TeapotError.invalidPayload)

            completion(result)

            return nil
        }
    }

    /// Downloads an image
    ///
    /// - Parameters:
    ///   - path: The relative path for the API call.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0. See URLRequest doc for more.
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    ///   - completion: The completion block, called with a NetworkImageResult once the request completes, always on main queue.
    /// - Returns: A URLSessionTask, if the request was successfully created, and nil otherwise.
    @discardableResult func downloadImage(path: String? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true, completion: @escaping ((NetworkImageResult) -> Void)) -> URLSessionTask? {
        do {
            let request = try self.request(verb: .get, path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular)

            let task = self.runTask(with: request) { (result: NetworkImageResult) in
                switch result {
                case .success(let image, let response):
                    // Handle non-2xx status as error.

                    if response.statusCode < 200 || response.statusCode > 299 {
                        let errorResult = NetworkImageResult(image, response, TeapotError.invalidResponseStatus(response.statusCode))
                        completion(errorResult)
                    } else {
                        completion(result)
                    }
                default:
                    completion(result)
                }
            }

            return task
        } catch {
            // Catch exceptions and handle them as errors for the client.
            let response = HTTPURLResponse(url: self.baseURL, statusCode: 400, httpVersion: nil, headerFields: headerFields)!
            let result = NetworkImageResult(nil, response, TeapotError.invalidPayload)

            completion(result)

            return nil
        }
    }

    /// Create a URL request for a given set of parameters.
    ///
    /// - Parameters:
    ///   - verb: The HTTP verb: GET/POST/PUT/DELETE, as an enum value.
    ///   - path: The relative path for the API call.
    ///   - parameters: a JSON object, to be sent as the HTTP body data.
    ///   - headerFields: A [String: String] dictionary mapping HTTP header field names to values. Defaults to nil.
    ///   - timeoutInterval: How many seconds before the request times out. Defaults to 15.0. See URLRequest doc for more.
    ///   - allowsCellular: a Bool indicating if this request should be allowed to run over cellular network or WLAN only.
    /// - Returns: URLRequest
    func request(verb: Verb, path: String? = nil, parameters: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 15.0, allowsCellular: Bool = true) throws -> URLRequest {
        guard var baseComponents = URLComponents(url: self.baseURL, resolvingAgainstBaseURL: true) else { throw TeapotError.invalidRequestPath }

        if let path = path, let pathURL = URL(string: path) {
            guard let pathComponents = URLComponents(url: pathURL, resolvingAgainstBaseURL: true) else {
                self.logger.errorLog("""

                ||
                || TEAPOT - REQUEST CONSTRUCTION ERROR
                || Could not get components for path \"\(String(describing: path))\"
                ||

                """)

                throw TeapotError.invalidRequestPath
            }

            baseComponents.path = pathComponents.path
            baseComponents.percentEncodedQuery = pathComponents.percentEncodedQuery
        }

        guard let url = baseComponents.url else {
            self.logger.errorLog("""

            ||
            || TEAPOT - REQUEST CONSTRUCTION ERROR
            || Could not get URL from components: \(baseComponents)
            ||

            """)

            throw TeapotError.invalidRequestPath
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        request.allowsCellularAccess = allowsCellular
        request.httpMethod = verb.rawValue

        var hasContentType = false

        if let headerFields = headerFields {
            for headerField in headerFields {
                if headerField.key == "Content-Type" {
                    hasContentType = true
                }
                request.setValue(headerField.value, forHTTPHeaderField: headerField.key)
            }
        }

        if let parameters = parameters {
            if (parameters.dictionary != nil || parameters.array != nil) && !hasContentType {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            request.httpBody = parameters.data
        }

        self.logger.incomingAndOutgoingDataLog("""

        ||
        || TEAPOT - OUTGOING REQUEST
        || Headers:
        || \(String(describing: request.allHTTPHeaderFields))
        ||
        || Contents:
        || \(Logger.logString(from: request.httpBody))
        ||

        """)
        return request
    }

    func runTask(with request: URLRequest, completion: @escaping ((NetworkResult) -> Void)) -> URLSessionTask {
        let task = self.session.dataTask(with: request) { [weak self] data, response, error in
            URLResponse.log(using: self?.logger, data, response, error)

            guard let response = response else {
                if let error = error {
                    guard (error as NSError).code != NSURLErrorCancelled else {
                        // This request was cancelled, do not actually fire the completion block.
                        return
                    }
                }

                let teapotError = TeapotError.noResponse(withUnderlyingError: error)
                let errorResponse = HTTPURLResponse(url: request.url!, statusCode: 400, httpVersion: nil, headerFields: request.allHTTPHeaderFields)!
                let errorResult = NetworkResult(nil, errorResponse, teapotError)
                completion(errorResult)

                return
            }

            var json: RequestParameter?
            if let data = data, let deserialised = try? JSONSerialization.jsonObject(with: data, options: []) {
                if let dictionary = deserialised as? [String: Any] {
                    json = RequestParameter(dictionary)
                } else if let array = deserialised as? [[String: Any]] {
                    json = RequestParameter(array)
                }
            }

            let result: NetworkResult
            if let underlyingError = error {
                result = NetworkResult(json, response as! HTTPURLResponse, TeapotError.dataTaskError(withUnderLyingError: underlyingError))
            } else {
                result = NetworkResult(json, response as! HTTPURLResponse, nil)
            }

            completion(result)
        }

        task.resume()

        return task
    }

    func runTask(with request: URLRequest, completion: @escaping ((NetworkImageResult) -> Void)) -> URLSessionTask {
        let task = self.session.dataTask(with: request) { [weak self] data, response, error in
            URLResponse.log(using: self?.logger, data, response, error)
            guard let response = response else {
                NSLog(error?.localizedDescription ?? "Major error with request: \(request).")

                return
            }

            var image: Image?
            if let data = data {
                image = Image(data: data)
            }

            let result: NetworkImageResult
            if let underlyingError = error {
                result = NetworkImageResult(image, response as! HTTPURLResponse, TeapotError.dataTaskError(withUnderLyingError: underlyingError))
            } else {
                result = NetworkImageResult(image, response as! HTTPURLResponse, nil)
            }

            completion(result)
        }

        self.runTaskQueue.async {
            task.resume()
        }

        return task
    }
}
