import Foundation

/// Wrapper for logs which can be toggled on and off to increase or decrease the amount of log barf you wish to see.
public class Logger {
    public enum LogLevel: Int {
        // Logs all data sent or received to the console, including the string representation of the data which was sent or received.
        case incomingAndOutgoingData

        // Logs all data received to the console, including the string representation of the data which was sent.
        case incomingData

        // Logs any errors to the console, including the string representation of the data which produced them.
        case error

        // Does not log anything to the console.
        case none
    }

    /// The current `LogLevel` for this instance of `Logger`.
    /// NOTE: In production, you should almost certainly use `.none`, which is also the default value.
    public var currentLevel: LogLevel

    /// Designated initializer.
    ///
    /// - Parameter level: The level to log at. Defaults to `.none`
    public init(level: LogLevel = .none) {
        self.currentLevel = level
    }

    /// Logs an item if the log level is `incomingAndOutgoing` or higher.
    ///
    /// - Parameters:
    ///   - items: What you wish to log.
    ///   - file: The file this log is coming from. Defaults to the directly calling file.
    ///   - line: The line this log is coming from. Defaults to the directly calling line.
    ///   - date: The date this
    /// - Returns: A boolean indicating whether the log printed or not, mostly for testing purposes.
    @discardableResult
    public func incomingAndOutgoingDataLog(_ items: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line, at date: Date = Date()) -> Bool {
        return self.log(level: .incomingAndOutgoingData, items: items, file: file, line: line, at: date)
    }

    /// Logs an item if the log level is `incomingOnly` or higher.
    ///
    /// - Parameters:
    ///   - items: What you wish to log.
    ///   - file: The file this log is coming from. Defaults to the directly calling file.
    ///   - line: The line this log is coming from. Defaults to the directly calling line.
    ///   - date: The date this
    /// - Returns: A boolean indicating whether the log printed or not, mostly for testing purposes.
    @discardableResult
    public func incomingDataLog(_ items: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line, at date: Date = Date()) -> Bool {
        return self.log(level: .incomingData, items: items, file: file, line: line, at: date)
    }

    /// Logs an item if the log level is `error` or higher.
    ///
    /// - Parameters:
    ///   - items: What you wish to log.
    ///   - file: The file this log is coming from. Defaults to the directly calling file.
    ///   - line: The line this log is coming from. Defaults to the directly calling line.
    ///   - date: The date this
    /// - Returns: A boolean indicating whether the log printed or not, mostly for testing purposes.
    @discardableResult
    public func errorLog(_ items: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line, at date: Date = Date()) -> Bool {
        return self.log(level: .error, items: items, file: file, line: line, at: date)
    }

    private func log(level: LogLevel, items: @autoclosure () -> String, file: StaticString, line: UInt, at date: Date) -> Bool {
        guard level.rawValue >= self.currentLevel.rawValue else {
            // We don't want to print anything at a level lower than the current log level.
            return false
        }

        print("TEAPOT - \(file) line \(line) at \(date): \(items())")
        return true
    }

    // MARK: - Formatting Helpers

    /// Takes Data and formats it into a string suitable for logging
    ///
    /// - Parameter data: The data you wish to log, or nil
    /// - Returns: The formatted string.
    public static func logString(from data: Data?) -> String {
        guard let data = data else { return "[no data]" }
        guard let dataString = String(data: data, encoding: .utf8) else { return "[data not convertible to UTF-8 string]" }

        return dataString
    }

    /// Takes the headers from a URLResponse and formats them into a string suitable for logging.
    ///
    /// - Parameter response: The response you wish to log headers from, or nil
    /// - Returns: The formatted string.
    public static func logHeaderString(from response: URLResponse?) -> String {
        guard let response = response else { return "[no response received]" }

        guard !response.asHTTP.allHeaderFields.isEmpty else { return "[no headers available]" }

        let headerStrings = response.asHTTP.allHeaderFields.map { "\($0): \($1)" }
        return headerStrings.joined(separator: "\n||\n\t")
    }
}
