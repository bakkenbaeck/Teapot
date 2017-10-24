import Foundation

public struct TeapotError: LocalizedError {
    static let invalidRequestPath = TeapotError(responseStatus: nil, type: .invalidRequestPath, errorDescription: NSLocalizedString("teapot_invalid_request_path", bundle: Teapot.localizationBundle, comment: ""))

    static let missingImage = TeapotError(responseStatus: nil, type: .missingImage, errorDescription: NSLocalizedString("teapot_missing_image", bundle: Teapot.localizationBundle, comment: ""))

    static func invalidResponseStatus(_ status: Int) -> TeapotError {
        return TeapotError(responseStatus: status, type: .invalidResponseStatus, errorDescription: String(format: NSLocalizedString("teapot_invalid_response_status", bundle: Teapot.localizationBundle, comment: ""), status))
    }

    static func missingMockFile(_ fileName: String) -> TeapotError {
        return TeapotError(responseStatus: nil, type: .missingMockFile, errorDescription: String(format: NSLocalizedString("mockteapot_missing_mock_file", bundle: Teapot.localizationBundle, comment: ""), fileName))
    }

    static func invalidMockFile(_ fileName: String) -> TeapotError {
        return TeapotError(responseStatus: nil, type: .invalidMockFile, errorDescription: String(format: NSLocalizedString("mockteapot_invalid_mock_file", bundle: Teapot.localizationBundle, comment: ""), fileName))
    }

    enum ErrorType {
        case invalidRequestPath
        case invalidResponseStatus
        case missingImage
        case missingMockFile
        case invalidMockFile
    }

    let responseStatus: Int?
    let type: ErrorType

    public var errorDescription: String?
}
