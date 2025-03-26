import Foundation

public protocol NotificationTransactionLoader {
    typealias ResultTransaction = Swift.Result<NotificationTransactionContent ,Error>
    
    func load(request: NotificationTransactionRequest, completion: @escaping (ResultTransaction) -> Void)
}
