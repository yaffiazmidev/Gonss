import Foundation

public protocol LiveDailyRankView {
    func display(_ viewModels: [LiveDailyRankViewModel])
    func displayPopularLive(_ viewModels: [LiveDailyRankViewModel])
}

public final class LiveDailyRankPresenter {
    
    private let view: LiveDailyRankView
    
    public init(view: LiveDailyRankView) {
        self.view = view
    }
    
    public func didFinishRequest(with rankings: [DailyRank]) {
        view.display(LiveDailyRankPresenter.map(rankings))
    }
    
    public func didFinishPopularRequest(with rankings: [DailyRank]) {
        view.displayPopularLive(LiveDailyRankPresenter.map(rankings))
    }
    
    private static func map(_ rankings: [DailyRank]) -> [LiveDailyRankViewModel] { 
//        var tempData: [DailyRank] =  rankings
//        tempData.append(contentsOf: rankings)
//        tempData.append(contentsOf: rankings)
//        tempData.append(contentsOf: rankings)
//        tempData.append(contentsOf: rankings)
//        tempData.append(contentsOf: rankings)
//        tempData.append(contentsOf: rankings)
        
        return rankings.compactMap {
            .init(
                userId: $0.account?.id ?? "",
                imageURL: $0.account?.photo,
                name: $0.account?.name ?? "-",
                isVerified: $0.account?.isVerified ?? false,
                totalLikes: formatNumber(Double($0.totalLike ?? 0))
            )
        }
    }
    
    private static func formatNumber(_ number: Double) -> String {
        let num = abs(number)
        let sign = (number < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000...:
            return String(format: "\(sign)%.1fB", num / 1_000_000_000)
        case 1_000_000...:
            return String(format: "\(sign)%.1fM", num / 1_000_000)
        case 1_000...:
            return String(format: "\(sign)%.1fK", num / 1_000)
        default:
            return String(format: "\(sign)%.0f", num)
        }
    }
}
