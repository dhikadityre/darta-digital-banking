import Foundation
@testable import PackageData

final class HTTPClientStub: HTTPClient, @unchecked Sendable {
    private struct Task: HTTPClientTask {
        func cancel() {}
    }
    
    struct RequestCall: Sendable {
        let url: URL
        let method: String
        let data: Data?
        let headers: [String: String]?
    }
    
    private let lock = NSLock()
    private var _requestCalls: [RequestCall] = []
    private var _stubbedResult: HTTPClient.Result?
    private var _urlStubbedResults: [URL: HTTPClient.Result] = [:]
    
    var requestCalls: [RequestCall] {
        lock.lock()
        defer { lock.unlock() }
        return _requestCalls
    }
    
    func stub(_ result: HTTPClient.Result) {
        lock.lock()
        defer { lock.unlock() }
        _stubbedResult = result
    }
    
    func stub(url: URL, result: HTTPClient.Result) {
        lock.lock()
        defer { lock.unlock() }
        _urlStubbedResults[url] = result
    }
    
    @discardableResult
    func get(from url: URL, headers: [String: String]?, completion: @escaping @Sendable (HTTPClient.Result) -> Void) -> HTTPClientTask {
        // 1. Kunci diaktifkan agar tidak ada thread lain yang bisa mengakses properti di bawah ini secara bersamaan.
        lock.lock() 

        _requestCalls.append(RequestCall(url: url, method: "GET", data: nil, headers: headers))
        let result = _urlStubbedResults[url] ?? _stubbedResult
        
        // // 2. Kunci dilepas segera setelah modifikasi & pembacaan selesai, sehingga thread lain bisa mengantre kembali.
        lock.unlock()
        
        if let result = result {
            completion(result)
        }
        return Task()
    }
    
    @discardableResult
    func post(to url: URL, data: Data?, headers: [String: String]?, completion: @escaping @Sendable (HTTPClient.Result) -> Void) -> HTTPClientTask {
        lock.lock()
        _requestCalls.append(RequestCall(url: url, method: "POST", data: data, headers: headers))
        let result = _urlStubbedResults[url] ?? _stubbedResult
        lock.unlock()
        
        if let result = result {
            completion(result)
        }
        return Task()
    }
}
