import Foundation

public protocol VerifyIdentityCountryLoader {
    typealias Result = Swift.Result<[VerifyIdentityCountryItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
