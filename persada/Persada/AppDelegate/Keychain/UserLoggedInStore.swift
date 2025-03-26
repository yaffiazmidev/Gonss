import Foundation
import KipasKipasShared
import KipasKipasLogin

struct LoggedInUser: Codable {
    let role: String
    let userName, userEmail, userMobile, accountId: String
    let photoUrl: String
    
    init(
        role: String,
        userName: String,
        userEmail: String,
        userMobile: String,
        accountId: String,
        photoUrl: String
    ) {
        self.role = role
        self.userName = userName
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.accountId = accountId
        self.photoUrl = photoUrl
    }
}

final class GenericKeychainStore<Data: Codable> {
    
    private var keychain: KKCaching {
        return KKCache.credentials
    }
    
    private let key: KKCache.Key
    
    var needAuth: (() -> Void)?
    
    init(key: KKCache.Key) {
        self.key = key
    }
    
    func insert(_ data: Data) {
        do {
            try keychain.save(value: data, key: key)
            
        } catch {
            print("Error Save Keychain: \(error.localizedDescription)")
        }
    }
    
    func retrieve() -> Data? {
        guard let loggedInUser = try? keychain.read(type: Data.self, key: key) else {
            needAuth?()
            return nil
        }
        
        return loggedInUser
    }
    
    func remove() {
        return keychain.remove(key: key)
    }
}
    
typealias LoggedUserKeychainStore = GenericKeychainStore<LoggedInUser>
typealias ProfileKeychainStore = GenericKeychainStore<LoginProfileResponse>
