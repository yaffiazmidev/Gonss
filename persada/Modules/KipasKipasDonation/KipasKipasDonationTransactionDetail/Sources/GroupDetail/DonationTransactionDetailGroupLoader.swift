import Foundation

public struct DonationTransactionDetailGroupRequest: Equatable {
    public let groupId: String
    
    public init(groupId: String) {
        self.groupId = groupId
    }
}

public protocol DonationTransactionDetailGroupLoader {
    typealias GroupResult = Swift.Result<DonationTransactionDetailGroupItem, Error>
    
    func load(request: DonationTransactionDetailGroupRequest, completion: @escaping (GroupResult) -> Void)
}
