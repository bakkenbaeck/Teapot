import UIKit

extension Teapot {
    /// Create multipart form data from UIImage
    ///
    /// - Parameters:
    ///   - image: image Image to be uploaded.
    ///   - boundary: boundary String boundary to split arguments. Should be the same value set in the Content-Type header.
    ///   - filename: filename A filename. Preferrably with matching UTI.
    /// - Returns: return data The properly encoded data. Create a RequestParameter with it to have it set as the request body.
    open func multipartData(from image: UIImage, boundary: String, filename: String) -> Data {
        var resultData = Data()

        // Boundary should start with --
        let startingLine = "--" + boundary + "\r\n"
        resultData.append(startingLine.data(using: .utf8)!)

        let disposition = "Content-Disposition: form-data; name=\"image\"; filename=\"" + filename + "\"\r\n"
        resultData.append(disposition.data(using: .utf8)!)

        // actual image data
        if let data = image.pngData() {
            let type = "Content-Type: image/png\r\n\r\n"
            resultData.append(type.data(using: .utf8)!)

            resultData.append(data)
        } else if let data = image.jpegData(compressionQuality: 1.0) {
            let type = "Content-Type: image/jpg\r\n\r\n"
            resultData.append(type.data(using: .utf8)!)

            resultData.append(data)
        }

        let dataSeparator = "\r\n"
        resultData.append(dataSeparator.data(using: .utf8)!)

        // Notice -- at the start and at the end
        let endingLine = "--" + boundary + "--\r\n"
        resultData.append(endingLine.data(using: .utf8)!)

        return resultData
    }

    /// Create multipart form data from Data
    ///
    /// - Parameters:
    ///   - data: data Binary data to be uploaded.
    ///   - boundary: boundary String boundary to split arguments. Should be the same value set in the Content-Type header.
    ///   - filename: filename A filename. Preferrably with matching UTI.
    /// - Returns: return data The properly encoded data. Create a RequestParameter with it to have it set as the request body.
    open func multipartData(from data: Data, boundary: String, filename: String) -> Data {
        var resultData = Data()

        // Boundary should start with --
        let startingLine = "--" + boundary + "\r\n"
        resultData.append(startingLine.data(using: .utf8)!)

        let disposition = "Content-Disposition: form-data; name=\"image\"; filename=\"" + filename + "\"\r\n"
        resultData.append(disposition.data(using: .utf8)!)

        // actual data
        let type = "Content-Type: application/octet-stream\r\n\r\n"
        resultData.append(type.data(using: .utf8)!)
        resultData.append(data)

        let dataSeparator = "\r\n"
        resultData.append(dataSeparator.data(using: .utf8)!)

        // Notice -- at the start and at the end
        let endingLine = "--" + boundary + "--\r\n"
        resultData.append(endingLine.data(using: .utf8)!)

        return resultData
    }
}
