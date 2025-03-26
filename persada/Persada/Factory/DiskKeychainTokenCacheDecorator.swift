import Foundation
import KipasKipasNetworking

class DiskKeychainTokenCacheDecorator: TokenCache {
    let decoratee: TokenCache
    
    init(decoratee: TokenCache) {
        self.decoratee = decoratee
    }
    
    func save(_ token: TokenItem, completion: @escaping (TokenCache.Result) -> Void) {
        
        decoratee.save(token) { result in
            if var login = retrieveCredentials() {
                login.token = token.accessToken
                login.accessToken = token.accessToken
                login.refreshToken = token.refreshToken
                login.loginResponseRefreshToken = token.refreshToken
                updateLoginData(data: login)
            }
            completion(result)
        }
    }
}
