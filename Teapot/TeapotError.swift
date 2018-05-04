import Foundation

public struct TeapotError: Error, CustomStringConvertible {
    static func dataTaskError(withUnderLyingError error: Error) -> TeapotError {
        let errorDescription = String(format: NSLocalizedString("teapot_data_task_error", bundle: Teapot.localizationBundle, comment: ""), error.localizedDescription)

        return TeapotError(withType: .dataTaskError, description: errorDescription, underlyingError: error)
    }

    static let invalidPayload = TeapotError(withType: .invalidPayload, description: NSLocalizedString("teapot_invalid_payload_path", bundle: Teapot.localizationBundle, comment: ""))

    static let invalidRequestPath = TeapotError(withType: .invalidRequestPath, description: NSLocalizedString("teapot_invalid_request_path", bundle: Teapot.localizationBundle, comment: ""))

    static let missingImage = TeapotError(withType: .missingImage, description: NSLocalizedString("teapot_missing_image", bundle: Teapot.localizationBundle, comment: ""))

    static func invalidResponseStatus(_ status: Int) -> TeapotError {
        let errorDescription = String(format: NSLocalizedString("teapot_invalid_response_status", bundle: Teapot.localizationBundle, comment: ""), status)

        return TeapotError(withType: .invalidResponseStatus, description: errorDescription, responseStatus: status)
    }

    static func missingMockFile(_ fileName: String) -> TeapotError {
        let errorDescription =  String(format: NSLocalizedString("mockteapot_missing_mock_file", bundle: Teapot.localizationBundle, comment: ""),  fileName)

        return TeapotError(withType: .missingMockFile, description: errorDescription)
    }

    static func invalidMockFile(_ fileName: String) -> TeapotError {
        let errorDescription =  String(format: NSLocalizedString("mockteapot_invalid_mock_file", bundle: Teapot.localizationBundle, comment: ""), fileName)
        
        return TeapotError(withType: .invalidMockFile, description: errorDescription)
    }

    static func incorrectHeaders(expected: [String: String], received: [String: String]?) -> TeapotError {
        let errorDescription = String(format: NSLocalizedString("mockteapot_invalid_headers", bundle: Teapot.localizationBundle, comment: ""), String(describing: received), String(describing: expected))

        return TeapotError(withType: .incorrectHeaders, description: errorDescription)
    }

    public enum ErrorType: Int {
        case dataTaskError
        case invalidPayload
        case invalidRequestPath
        case invalidResponseStatus
        case missingImage
        case missingMockFile
        case invalidMockFile
        case incorrectHeaders
    }

    public let responseStatus: Int?
    public let underlyingError: Error?
    public let type: ErrorType

    public var description: String

    public init(withType type: ErrorType, description: String, responseStatus: Int? = nil, underlyingError: Error? = nil) {
        
        self.type = type
        self.description = description
        self.responseStatus = responseStatus
        self.underlyingError = underlyingError
    }
}
