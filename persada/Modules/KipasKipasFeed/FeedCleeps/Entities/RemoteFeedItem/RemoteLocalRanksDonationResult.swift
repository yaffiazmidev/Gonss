import Foundation


// MARK: - RemoteLocalRankDonate
public struct RemoteLocalRankDonate: Codable {
    
    public var content: [RemoteLocalRankDonateContent]?

    public init(content: [RemoteLocalRankDonateContent]?) {
        self.content = content
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.content = try container.decodeIfPresent([RemoteLocalRankDonateContent].self, forKey: .content)
    }
}
// MARK: - Content
public struct RemoteLocalRankDonateContent: Codable {
    public var account: RemoteFeedItemAccount?
    
    public init(account: RemoteFeedItemAccount?) {
        self.account = account
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.account = try container.decodeIfPresent(RemoteFeedItemAccount.self, forKey: .account)
    }
}

