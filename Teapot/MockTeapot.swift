import Foundation
@testable import TeapotMac

class MockTeapot: Teapot {

    public enum MockError: Error {
        case missingMockFile
        case invalidMockFile
    }

    override func execute(verb: Verb, path: String, parameters: RequestParameter? = nil, headerFields: [String: String]? = nil, timeoutInterval: TimeInterval = 5.0, allowsCellular: Bool = true, completion: @escaping((NetworkResult) -> Void)) {
        getMockedData(forPath: path) { json, error in

            let response = HTTPURLResponse(url: URL(string: path)!, statusCode: 200, httpVersion: nil, headerFields: nil)
            let requestParameter = json != nil ? RequestParameter(json!) : nil
            
            let networkResult = NetworkResult(requestParameter, response!, error)

            completion(networkResult)
        }
    }

    func getMockedData(forPath path: String, completion: @escaping(([String: Any]?, Error?) -> Void)) {
        let components = path.components(separatedBy: "/")
        let resource = components.last
        
        if let filePath = Bundle.main.path(forResource: resource, ofType: "json") {
            let url = URL(fileURLWithPath: filePath)
            do {
                let data = try Data(contentsOf: url)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    completion(json, nil)
                } else {
                    completion(nil, MockError.invalidMockFile)
                }
            } catch let error {
                completion(nil, MockError.invalidMockFile)
            }
        } else {
            completion(nil, MockError.missingMockFile)
        }
    }
}
