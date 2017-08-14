import Foundation

/// RequestParameter enum, to encapsulate JSON object (either dictionaries or arrays) and simple multipart data.
///
/// - dictionary: [String: Any] dictionary or nil if array or invalid data.
/// - array: [[String: Any]] array or nil if dictionary or invalid data.
/// - data: Data data from the array, dictionary or multipart form data.
public enum RequestParameter {
    case dictionary(Dictionary<String, Any>)

    case array(Array<Dictionary<String, Any>>)

    case data(Data)

    public var dictionary: (Dictionary<String, Any>)? {
        switch self {
        case .dictionary(let d):
            return d
        default:
            return nil
        }
    }

    public var array: (Array<Dictionary<String, Any>>)? {
        switch self {
        case .array(let a):
            return a
        default:
            return nil
        }
    }

    public var data: Data? {
        switch self {
        case .data(let data):
            return data
        case .array(let array):
            return try? JSONSerialization.data(withJSONObject: array, options: [])
        case .dictionary(let dictionary):
            return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        }
    }

    public init(_ dictionary: [String: Any]) {
        self = .dictionary(dictionary)
    }

    public init(_ array: [[String: Any]]) {
        self = .array(array)
    }

    public init(_ data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let array = json as? Array<Dictionary<String, Any>> {
            self = .array(array)
        } else if let dict = json as? Dictionary<String, Any> {
            self = .dictionary(dict)
        } else {
            self = .data(data)
        }
    }
}
