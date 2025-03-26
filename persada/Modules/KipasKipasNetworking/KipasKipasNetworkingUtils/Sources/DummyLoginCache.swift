import Foundation

public class DummyLoginCache: NSObject {
    
    private static let key = "DummyLoginCache"
    
    public static let instance = DummyLoginCache()
    
    private let userDefaults: UserDefaults
    
    override init() {
        userDefaults = UserDefaults.standard
    }
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    func saveValue(value: Bool){
        userDefaults.set(value, forKey: DummyLoginCache.key)
    }
    
    public func getValue() -> Bool? {
        return userDefaults.bool(forKey: DummyLoginCache.key)
    }
    
    public func save(_ value: Any, forKey key: Key) {
        userDefaults.set(value, forKey: key.rawValue)
    }
    
    public func retrieve<T>(forKey key: Key) -> T? {
        return userDefaults.value(forKey: key.rawValue) as? T
    }
}

public extension DummyLoginCache {
    enum Key: String {
        case isLoggedIn
        case accountId
    }
}
