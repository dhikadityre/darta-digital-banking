import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from url: URL, headers: [String: String]?, completion: @escaping (Result) -> Void) -> HTTPClientTask
    
    @discardableResult
    func post(to url: URL, data: Data?, headers: [String: String]?, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    private let lock = NSLock()
    private var isRefreshing = false
    private var refreshQueue: [() -> Void] = []
    
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
    
    private func execute(_ request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let response = response as? HTTPURLResponse, response.statusCode == 401 {
                let path = request.url?.path ?? ""
                if path.contains("/api/auth/login") || path.contains("/api/auth/refresh") {
                    completion(Swift.Result {
                        if let error = error { throw error }
                        guard let data = data, let response = response as? HTTPURLResponse else {
                            throw UnexpectedValuesRepresentation()
                        }
                        return (data, response)
                    })
                    return
                }
                
                let authHeader = request.value(forHTTPHeaderField: "Authorization") ?? ""
                let expiredToken = authHeader.replacingOccurrences(of: "Bearer ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !expiredToken.isEmpty else {
                    completion(Swift.Result {
                        if let error = error { throw error }
                        guard let data = data, let response = response as? HTTPURLResponse else {
                            throw UnexpectedValuesRepresentation()
                        }
                        return (data, response)
                    })
                    return
                }
                
                self.handleUnauthorizedError(expiredToken: expiredToken) { refreshResult in
                    switch refreshResult {
                    case let .success(newToken):
                        var retryRequest = request
                        retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                        let retryTask = self.session.dataTask(with: retryRequest) { retryData, retryResponse, retryError in
                            completion(Swift.Result {
                                if let retryError = retryError { throw retryError }
                                guard let retryData = retryData, let retryResponse = retryResponse as? HTTPURLResponse else {
                                    throw UnexpectedValuesRepresentation()
                                }
                                return (retryData, retryResponse)
                            })
                        }
                        retryTask.resume()
                        
                    case .failure:
                        completion(Swift.Result {
                            if let error = error { throw error }
                            guard let data = data, let response = response as? HTTPURLResponse else {
                                throw UnexpectedValuesRepresentation()
                            }
                            return (data, response)
                        })
                    }
                }
            } else {
                completion(Swift.Result {
                    if let error = error { throw error }
                    guard let data = data, let response = response as? HTTPURLResponse else {
                        throw UnexpectedValuesRepresentation()
                    }
                    return (data, response)
                })
            }
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
    
    private func handleUnauthorizedError(
        expiredToken: String,
        completion: @escaping (Swift.Result<String, Error>) -> Void
    ) {
        lock.lock()
        
        let storedToken = TokenManager.shared.token ?? ""
        if !storedToken.isEmpty && storedToken != expiredToken {
            lock.unlock()
            completion(.success(storedToken))
            return
        }
        
        if isRefreshing {
            refreshQueue.append {
                let freshToken = TokenManager.shared.token ?? ""
                if !freshToken.isEmpty {
                    completion(.success(freshToken))
                } else {
                    completion(.failure(URLError(.userAuthenticationRequired)))
                }
            }
            lock.unlock()
            return
        }
        
        isRefreshing = true
        lock.unlock()
        
        performTokenRefresh(expiredToken: expiredToken) { [weak self] result in
            guard let self = self else { return }
            
            self.lock.lock()
            self.isRefreshing = false
            
            switch result {
            case let .success((newToken, newRefreshToken)):
                TokenManager.shared.token = newToken
                TokenManager.shared.refreshToken = newRefreshToken
                completion(.success(newToken))
                
                let queuedCompletions = self.refreshQueue
                self.refreshQueue.removeAll()
                self.lock.unlock()
                
                queuedCompletions.forEach { $0() }
                
            case let .failure(error):
                TokenManager.shared.clear()
                completion(.failure(error))
                
                let queuedCompletions = self.refreshQueue
                self.refreshQueue.removeAll()
                self.lock.unlock()
                
                queuedCompletions.forEach { $0() }
            }
        }
    }
    
    private func performTokenRefresh(expiredToken: String, completion: @escaping (Swift.Result<(String, String), Error>) -> Void) {
        guard let baseURL = Config.apiBaseUrl else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let refreshURL = baseURL.appendingPathComponent("/api/auth/refresh")
        
        let storedRefreshToken = TokenManager.shared.refreshToken ?? ""
        let refreshRequestBody = RefreshRequest(refreshToken: storedRefreshToken)
        
        var request = URLRequest(url: refreshURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(refreshRequestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
                completion(.failure(URLError(.userAuthenticationRequired)))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotDecodeContentData)))
                return
            }
            
            do {
                let refreshResponse = try JSONDecoder().decode(RefreshResponse.self, from: data)
                completion(.success((refreshResponse.token, refreshResponse.refreshToken)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    @discardableResult
    public func get(from url: URL, headers: [String: String]?, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return execute(request, completion: completion)
    }
    
    @discardableResult
    public func post(to url: URL, data: Data?, headers: [String: String]?, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = data
        return execute(request, completion: completion)
    }
}

public extension HTTPClient {
    func get(from url: URL, headers: [String: String]? = nil) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            get(from: url, headers: headers) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func post(to url: URL, data: Data?, headers: [String: String]? = nil) async throws -> (Data, HTTPURLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            post(to: url, data: data, headers: headers) { result in
                continuation.resume(with: result)
            }
        }
    }
}

public final class RemoteMapper {
    private init() {}
    
    public static func map<T: Decodable>(_ data: Data, _ response: HTTPURLResponse, decoder: JSONDecoder = JSONDecoder()) throws -> T {
        if let dateHeader = response.value(forHTTPHeaderField: "Date") {
            TimeSyncTracker.shared.syncTime(withServerDateString: dateHeader)
        }
        
        guard (200..<300).contains(response.statusCode) else {
            if let apiError = try? decoder.decode(ApiError.self, from: data) {
                throw apiError
            }
            throw URLError(.init(rawValue: response.statusCode))
        }
        return try decoder.decode(T.self, from: data)
    }
}

