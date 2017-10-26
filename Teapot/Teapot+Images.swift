import Foundation

extension Teapot {
    open func get(_ path: String? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping ((NetworkImageResult) -> Void)) {
        var headerFields = headerFields ?? [String: String]()

        // defaults to PNG
        if self.baseURL.absoluteString.hasSuffix("jpg") {
            headerFields["Content-Type"] = "image/jpg"
        } else if self.baseURL.absoluteString.hasSuffix("gif") {
            headerFields["Content-Type"] = "image/gif"
        } else {
            headerFields["Content-Type"] = "image/png"
        }

        self.downloadImage(path: path, headerFields: headerFields, timeoutInterval: timeoutInterval, allowsCellular: allowsCellular, completion: completion)
    }
}
