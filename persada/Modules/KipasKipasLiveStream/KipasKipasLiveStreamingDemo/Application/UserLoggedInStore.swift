import Foundation
import KipasKipasShared

struct LoggedInUser: Codable {
    let role: String
    let userName, userEmail, userMobile, accountId: String
    
    init(
        role: String,
        userName: String,
        userEmail: String,
        userMobile: String,
        accountId: String
    ) {
        self.role = role
        self.userName = userName
        self.userEmail = userEmail
        self.userMobile = userMobile
        self.accountId = accountId
    }
}

final class LoggedUserKeychainStore {
    
    private var keychain: KKCaching {
        return KKCache.credentials
    }
    
    private let key: KKCache.Key = .loggedInUser
    
    typealias InsertionResult = Swift.Result<Void, Error>
   
    func insert(_ user: LoggedInUser, completion: @escaping (InsertionResult) -> Void) {
        do {
            try keychain.save(value: user, key: key)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func retrieve() -> LoggedInUser? {
        return try? keychain.read(type: LoggedInUser.self, key: key)
    }
    
    func remove() {
        return keychain.remove(key: key)
    }
}
