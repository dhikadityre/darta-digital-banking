import Foundation

public final class TokenManager {
    public static let shared = TokenManager()
    
    private init() {}
    
    public var token: String? {
        get { UserDefaults.standard.string(forKey: "auth_token") }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: "auth_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "auth_token")
            }
        }
    }
    
    public var accessToken: String? {
        get { token }
        set { token = newValue }
    }
    
    public var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: "refresh_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "refresh_token")
            }
        }
    }
    
    public func clear() {
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
    }
}
