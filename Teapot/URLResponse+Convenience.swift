import Foundation

extension URLResponse {

    var asHTTP: HTTPURLResponse {
        return self as! HTTPURLResponse
    }

    var statusCode: Int {
        return self.asHTTP.statusCode
    }

    var allHeaderFields: [String: String] {
        return self.asHTTP.allHeaderFields
    }

    static func log(using logger: Logger?, _ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard let logger = logger else {
            // Can't log without a logger.
            return
        }

        guard let response = response else {
            logger.errorLog("""

                ||
                || TEAPOT - NO RESPONSE
                ||
                || Error:
                || \t\(String(describing: error))
                ||

                """)
            return
        }

        if let receivedError = error {
            logger.errorLog("""

                ||
                || TEAPOT - RECIEVED ERROR
                ||
                || HTTP status code: \(response.statusCode)
                ||
                || Error:
                || \t\(receivedError)
                ||
                || Headers:
                || \t\(Logger.logHeaderString(from: response))
                ||
                || Contents:
                || \t\(Logger.logString(from: data))

                """)
        } else {
            logger.incomingOnlyLog("""

                ||
                || TEAPOT - RECIEVED DATA
                ||
                || HTTP status code: \(response.statusCode)
                ||
                || Headers:
                || \t\(Logger.logHeaderString(from: response))
                ||
                || Contents:
                || \t\(Logger.logString(from: data))

            """)
        }
    }
}
