import Foundation
import KipasKipasShared

#warning("[BEKA] Get rid of this")
public final class OneSignalManager {
    
    public static let shared: OneSignalManager = OneSignalManager()
    
    private var _baseURL: String = ""
    private var _appId: String = ""
    private var _apiKey: String = ""
    
    private init() {}
    
    public var baseURL: String {
        /// Because the URL is one-for-all it's okay to simply hardcode it (for now) this will simplify the fix
       return "https://onesignal.com/api/v1/notifications"
    }
    
    public var appId: String {
        get {
            return _appId
        } set {
            _appId = newValue
        }
    }
    
    public var apiKey: String {
        get {
            return _apiKey
        } set {
            _apiKey = newValue
        }
    }
}
