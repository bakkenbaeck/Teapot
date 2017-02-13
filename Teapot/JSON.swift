import Foundation


/// JSON enum, to encapsulate JSON objects being either dictionaries or arrays.
///
/// - dictionary: [String: Any] dictionary or nil if array or invalid data.
/// - array: [[String: Any]] array or nil if dictionary or invalid data.
public enum JSON {
    case dictionary(Dictionary<String, Any>)

    case array(Array<Dictionary<String, Any>>)

    public var dictionary: (Dictionary<String, Any>)? {
        get {
            switch self {
            case .dictionary(let d):
                return d
            default:
                return nil
            }
        }
    }

    public var array: (Array<Dictionary<String, Any>>)? {
        get {
            switch self {
            case .array(let a):
                return a
            default:
                return nil
            }
        }
    }

    public var data: Data? {
        get {
            switch self {
            case .array(let array):
                return try? JSONSerialization.data(withJSONObject: array, options: [])
            case .dictionary(let dictionary):
                return try? JSONSerialization.data(withJSONObject: dictionary, options: [])
            }
        }
    }

    public init(_ dictionary: [String: Any]) {
        self = .dictionary(dictionary)
    }

    public init(_ array: [[String: Any]]) {
        self = .array(array)
    }
}
