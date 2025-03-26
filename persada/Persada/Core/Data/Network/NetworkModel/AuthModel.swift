import Foundation
import KipasKipasLogin

let AUTH = AuthModel.share

public class AuthModel: NSObject {
    public static let share = AuthModel()
    
    public override init() {}
    
    public func isLogin() -> Bool {
        return getToken() != nil
    }
    
    public func isTokenExpired() -> Bool {
        return Date() > getTokenExpiresDate()
    }
    
    func refreshToken(refreshToken: String) {
        let network: AuthNetworkModel = AuthNetworkModel()
        network.login(.refreshToken(refreshToken: refreshToken)) { (data) in
            switch data {
            case .success(let dataLogin):
                updateLoginData(data: dataLogin)
            case .failure(let error):
                print(error)
            }
        }
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
