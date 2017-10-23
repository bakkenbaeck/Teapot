import Foundation

extension Teapot {
    public struct TeapotError: LocalizedError {
        static let invalidRequestPath = TeapotError(responseStatus: -1, type: .invalidRequestPath, errorDescription: NSLocalizedString("teapot_invalid_request_path", bundle: Teapot.localizationBundle, comment: ""))

        static let missingImage = TeapotError(responseStatus: -1, type: .missingImage, errorDescription: NSLocalizedString("teapot_missing_image", bundle: Teapot.localizationBundle, comment: ""))

        static func invalidResponseStatus(_ status: Int) -> TeapotError {
            return TeapotError(responseStatus: status, type: .invalidResponseStatus, errorDescription: String(format: NSLocalizedString("teapot_invalid_response_status", bundle: Teapot.localizationBundle, comment: ""), status))
        }

        enum ErrorType {
            case invalidRequestPath
            case invalidResponseStatus
            case missingImage
        }

        let responseStatus: Int
        let type: ErrorType

        public var errorDescription: String?
    }
}
