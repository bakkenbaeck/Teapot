import UIKit

extension Teapot {
    open func multipartData(from image: UIImage, boundary: String, filename: String) -> Data {
        var resultData = Data()

        // Boundary should start with --
        let startingLine = "--" + boundary + "\r\n"
        resultData.append(startingLine.data(using: .utf8)!)

        let disposition = "Content-Disposition: form-data; name=\"image\"; filename=\"" + filename + "\"\r\n"
        resultData.append(disposition.data(using: .utf8)!)

        // actual image data
        if let data = UIImagePNGRepresentation(image) {
            let type = "Content-Type: image/png\r\n\r\n"
            resultData.append(type.data(using: .utf8)!)

            resultData.append(data)
        } else if let data = UIImageJPEGRepresentation(image, 1.0) {
            let type = "Content-Type: image/jpg\r\n\r\n"
            resultData.append(type.data(using: .utf8)!)

            resultData.append(data)
        }

        let dataSeparator = "\r\n"
        resultData.append(dataSeparator.data(using: .utf8)!)

        //Notice -- at the start and at the end
        let endingLine = "--" + boundary + "--\r\n"
        resultData.append(endingLine.data(using: .utf8)!)
        
        return resultData
    }
}
