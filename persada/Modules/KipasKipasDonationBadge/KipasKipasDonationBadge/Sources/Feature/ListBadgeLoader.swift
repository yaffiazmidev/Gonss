import Foundation

public protocol ListBadgeLoader {
    
    typealias Result = Swift.Result<[Badge], Error>
    func loadBadge(completion: @escaping (Result) -> Void)
    func updateBadge(isShowBadge: Bool, completion: @escaping (Error?) -> Void)
}
