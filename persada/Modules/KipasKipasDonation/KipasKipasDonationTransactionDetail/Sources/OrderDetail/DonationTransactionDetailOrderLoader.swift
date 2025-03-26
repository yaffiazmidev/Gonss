import Foundation
import KipasKipasShared

public struct DonationTransactionDetailOrderRequest: Equatable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public protocol DonationTransactionDetailOrderLoader {
    typealias DonationTransactionDetailResult = Swift.Result<DonationTransactionDetailOrderItem, Error>
    
    func load(request: DonationTransactionDetailOrderRequest, completion: @escaping (DonationTransactionDetailResult) -> Void)
}

