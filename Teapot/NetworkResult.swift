import Foundation

/// NetworkResult
///
/// This is passed by the Network layer completion blocks. The client implementation should know ahead of time if JSON is dictionary or array.
/// Or acount for the possibility of both by using a switch.
///
/// - success: Contains an optional JSON and an HTTPURLResponse. The parsing layer should know ahead of time if JSON is dictionary or array.
/// - failure: Contains an optional JSON, an HTTPURLResponse and an Error. The parsing layer should know ahead of time if JSON is dictionary or array.
public enum NetworkResult {
    case success(JSON?, HTTPURLResponse)

    case failure(JSON?, HTTPURLResponse, Error)

    public init(_ json: JSON?, _ response: HTTPURLResponse, _ error: Error? = nil) {
        if let error = error {
            self = .failure(json, response, error)
        } else {
            self = .success(json, response)
        }
    }
}
