import Foundation
import Security

public protocol TokenStorage {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func save(accessToken: String, refreshToken: String)
    func clear()
}

// MARK: - STEP 3.0
public final class KeychainTokenStorage: TokenStorage, @unchecked Sendable {
    private let service = "com.mediatamaidtech.darta"
    private let accountAccessToken = "accessToken"
    private let accountRefreshToken = "refreshToken"
    
    public init() {}
    
    public var accessToken: String? {
        read(forKey: accountAccessToken)
    }
    
    public var refreshToken: String? {
        read(forKey: accountRefreshToken)
    }
    
    public func save(accessToken: String, refreshToken: String) {
        write(accessToken, forKey: accountAccessToken)
        write(refreshToken, forKey: accountRefreshToken)
    }
    
    public func clear() {
        delete(forKey: accountAccessToken)
        delete(forKey: accountRefreshToken)
    }
    
    private func write(_ value: String, forKey key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var newQuery = query
            newQuery[kSecValueData as String] = data
            SecItemAdd(newQuery as CFDictionary, nil)
        }
    }
    
    private func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    private func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

public final class TokenManager: @unchecked Sendable {
    public static let shared = TokenManager()
    
    var storage: TokenStorage
    
    public init(storage: TokenStorage = KeychainTokenStorage()) {
        self.storage = storage
    }
    
    public var token: String? {
        get { storage.accessToken }
        set {
            if let newValue = newValue {
                storage.save(accessToken: newValue, refreshToken: storage.refreshToken ?? "")
            } else {
                storage.save(accessToken: "", refreshToken: storage.refreshToken ?? "")
            }
        }
    }
    
    public var accessToken: String? {
        get { token }
        set { token = newValue }
    }
    
    public var refreshToken: String? {
        get { storage.refreshToken }
        set {
            if let newValue = newValue {
                storage.save(accessToken: storage.accessToken ?? "", refreshToken: newValue)
            } else {
                storage.save(accessToken: storage.accessToken ?? "", refreshToken: "")
            }
        }
    }
    
    public func clear() {
        storage.clear()
    }
}
