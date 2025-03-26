import Foundation
import KipasKipasNetworking

final class DonationTransactionDetailGroupItemMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> DonationTransactionDetailGroupItem {
        guard response.isOK else {
            guard let error = try? JSONDecoder().decode(KKErrorNetworkRemoteResponse.self, from: data) else {
                throw KKNetworkError.invalidData
            }
            throw KKNetworkError.responseFailure(KKErrorNetworkResponse.fromRemote(error))
        }
        
        guard let root = try? JSONDecoder().decode(RemoteDonationTransactionGroupRoot.self, from: data) else {
            throw KKNetworkError.invalidData
        }
        
        let donations = root.data?.donations?.map {
            return DonationGroupItem(postDonationID: $0.postDonationId ?? "", title: $0.title ?? "", urlPhoto: $0.urlPhoto ?? "", amount: $0.amount ?? 0)
        } ?? []
        
        return DonationTransactionDetailGroupItem(
            donations: donations,
            totalAmount: root.data?.totalAmount ?? 0
        )
    }
}
