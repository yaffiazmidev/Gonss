import Foundation
import KipasKipasNetworking

public final class RemoteDonationGlobalRankLoader: DonationGlobalRankLoader {
    
    public typealias Result = DonationGlobalRankLoader.Result
    
    public let baseURL: URL
    public let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func load(_ request: DonationGlobalRankRequest, completion: @escaping (Result) -> Void) {
        let url = GlobalRankEndpoint.getGlobalRank(request).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: url)
                completion(RemoteDonationGlobalRankLoader.map(data, from: response))
            } catch {
                completion(.failure(KKNetworkError.connectivity))
            }
        }
    }
}

private extension RemoteDonationGlobalRankLoader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let response = try Mapper<Root<[RemoteDonationGlobalRank]>>.map(data, from: response)
            return .success(response.data.asItems)
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteDonationGlobalRank {
    var accountName: String {
        return shouldShowBadge ? (account?.name ?? "") : "Orang Dermawan"
    }
    
    var accountUsername: String {
        return "@" + (account?.username ?? "")
    }
    
    var accountPhotoURL: String {
        return account?.photo ?? ""
    }
    
    var shouldShowBadge: Bool {
        return account?.isShowBadge == true
    }
    
    var donatedDescription: String {
        let amount = account?.totalDonation ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "id-ID")
        
        return "Berdonasi " + numberFormatter.string(from: NSNumber(value: amount))!
    }
}

private extension Array where Element == RemoteDonationGlobalRank {
    var asItems: [DonationGlobalRankItem] {
        return compactMap { $0.asItem }
    }
}

extension RemoteDonationGlobalRank {
    var asItem: DonationGlobalRankItem {
        .init(
            id: id ?? "",
            rank: globalRank ?? 0,
            name: accountName,
            username: accountUsername,
            statusRank: DonationGlobalRankItem.StatusRank(rawValue: statusRank ?? "") ?? .STAY,
            profileImageURL: accountPhotoURL,
            badgeURL: url ?? "",
            isShowBadge: shouldShowBadge,
            donatedDescription: donatedDescription
        )
    }
}
