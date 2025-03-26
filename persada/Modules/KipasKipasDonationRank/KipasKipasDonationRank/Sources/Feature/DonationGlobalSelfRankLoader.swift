import Foundation

public protocol DonationGlobalSelfRankLoader {
    typealias Result = Swift.Result<DonationGlobalRankItem, Error>
    func loadSelfRank(accountId: String, completion: @escaping (Result) -> Void)
}
