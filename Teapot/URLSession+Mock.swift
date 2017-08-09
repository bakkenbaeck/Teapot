import Foundation

class MockURLSession: URLSession {
    var request: URLRequest?

    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.request = request


        return super.dataTask(with: request, completionHandler: completionHandler)
    }
}