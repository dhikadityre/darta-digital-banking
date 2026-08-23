import Foundation
@testable import PackageData

final class FakeTokenStorage: TokenStorage, @unchecked Sendable {
    var accessToken: String?
    var refreshToken: String?
    
    func save(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func clear() {
        accessToken = nil
        refreshToken = nil
    }
}
