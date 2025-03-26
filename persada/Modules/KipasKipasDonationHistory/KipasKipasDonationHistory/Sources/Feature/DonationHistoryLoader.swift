import Foundation
import KipasKipasNetworking

public protocol DonationHistoryLoader {
    typealias Result = Swift.Result<Root<[RemoteDonationHistory]>, Error>
    func load(request: DonationHistoryRequest, completion: @escaping (Result) -> Void)
}
