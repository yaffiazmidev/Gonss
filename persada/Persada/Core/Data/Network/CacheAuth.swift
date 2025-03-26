import Foundation
import KipasKipasLogin

class CacheAuth: NSObject {
    public static let share = CacheAuth()
    
    public override init() {}
    
    public func isLogin() -> Bool {
        var _isLogin: Bool = false
        if let getToken = retrieveCredentials() {
            if getToken.accessToken != nil {
                _isLogin = true
            } else {
                _isLogin = false
            }
        }else{
            _isLogin = false
        }
        return _isLogin
    }
    
    public func getAccessToken() -> String? {
        var _accessToken: String?
        CACHE.retrievedObject(LoginResponse.self, to: .caches, as: KeyObject.authLogin, onSuccess: { object in
            if object.accessToken != nil {
                _accessToken = object.accessToken
            } else {
                _accessToken = nil
            }
        }) {
            _accessToken = nil
        }
        return _accessToken
    }
    
    public func getUser() -> LoginResponse? {
        var _user: LoginResponse?
        CACHE.retrievedObject(LoginResponse.self, to: .caches, as: KeyObject.authLogin, onSuccess: { object in
            _user = object
        }) {
            _user = nil
        }
        return _user
    }
}
