import Foundation
import KipasKipasShared

#warning("[BEKA] Get rid of this")
public final class APIConstants {
    
    public static let shared: APIConstants = APIConstants()
    
    public var baseUrl: String {
        do {
            return try KKCache.common.read(type: String.self, key: .baseURL) ?? ""
        } catch _ {
            return ""
        }
    }
}
