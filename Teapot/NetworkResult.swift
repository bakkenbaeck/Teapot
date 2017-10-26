import Foundation

#if os(iOS) || os(watchOS) || os(tvOS)
    import UIKit
    public typealias Image = UIImage
#elseif os(OSX)
    import AppKit
    public typealias Image = NSImage
#endif

/// NetworkResult
///
/// This is passed by the Network layer completion blocks. The client implementation should know ahead of time if JSON is dictionary or array.
/// Or account for the possibility of both by using a switch.
///
/// - success: Contains an optional JSON and an HTTPURLResponse. The parsing layer should know ahead of time if JSON is dictionary or array.
/// - failure: Contains an optional JSON, an HTTPURLResponse and an Error. The parsing layer should know ahead of time if JSON is dictionary or array.
public enum NetworkResult {
    case success(RequestParameter?, HTTPURLResponse)

    case failure(RequestParameter?, HTTPURLResponse, TeapotError)

    public init(_ json: RequestParameter?, _ response: HTTPURLResponse, _ error: TeapotError? = nil) {
        if let error = error {
            self = .failure(json, response, error)
        } else {
            self = .success(json, response)
        }
    }
}

public enum NetworkImageResult {
    case success(Image, HTTPURLResponse)

    case failure(HTTPURLResponse, TeapotError)

    public init(_ image: Image?, _ response: HTTPURLResponse, _ error: TeapotError? = nil) {
        if let error = error {
            self = .failure(response, error)
        } else if image == nil {
            self = .failure(response, TeapotError.missingImage)
        } else {
            self = .success(image!, response)
        }
    }
}
