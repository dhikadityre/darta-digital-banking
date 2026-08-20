import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    @discardableResult
    func post(to url: URL, data: Data?, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    @discardableResult
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    @discardableResult
    public func post(to url: URL, data: Data?, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}

public extension HTTPClient {
    func get(from url: URL) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            get(from: url) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func post(to url: URL, data: Data?) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            post(to: url, data: data) { result in
                continuation.resume(with: result)
            }
        }
    }
}

public final class RemoteMapper {
    private init() {}
    
    public static func map<T: Decodable>(_ data: Data, _ response: HTTPURLResponse, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        guard (200..<300).contains(response.statusCode) else {
            if let apiError = try? decoder.decode(ApiError.self, from: data) {
                throw apiError
            }
            throw URLError(.init(rawValue: response.statusCode))
        }
        return try decoder.decode(T.self, from: data)
    }
}

