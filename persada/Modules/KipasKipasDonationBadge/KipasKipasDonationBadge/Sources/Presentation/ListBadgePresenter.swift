import Foundation

public protocol ListBadgeView {
    func display(_ viewModel: ListBadgeViewModel)
    func display(_ isUpdateSuccessful: Bool)
}

public protocol ListBadgeLoadingView {
    func display(_ viewModel: ListBadgeLoadingViewModel)
}

public final class ListBadgePresenter {
    
    private let view: ListBadgeView
    private let loadingView: ListBadgeLoadingView
    
    public init(
        view: ListBadgeView,
        loadingView: ListBadgeLoadingView
    ) {
        self.view = view
        self.loadingView = loadingView
    }
    
    public func didStartLoading() {
        loadingView.display(.init(isLoading: true))
    }
    
    public func didFinishLoad(with badges: [Badge]) {
        loadingView.display(.init(isLoading: false))
        view.display(.init(badges: ListBadgePresenter.map(badges)))
    }
    
    public func didFinishUpdateBadge(with error: Error?) {
        view.display(error == nil)
    }
    
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "id-ID")
        return numberFormatter
    }()
    
    private static func map(_ badges: [Badge]) -> [BadgeViewModel] {
        return badges.compactMap {
            let isBadgeUnlocked = $0.diffNominalBadge == 0
            let badgeMessage = badgeMessage(
                isBadgeUnlocked: isBadgeUnlocked,
                diffAmount: $0.diffNominalBadge ?? 0
            )
            return .init(
                id: $0.id ?? UUID().uuidString,
                badgeName: $0.name ?? "",
                badgeURL: URL(string: $0.url ?? ""),
                isShowBadge: $0.isShowBadge ?? false,
                isMyBadge: $0.isMyBadge ?? false,
                badgeAmountRangeDescription: formatAmount(
                    lowestRange: $0.min ?? 0,
                    highestRange: $0.max ?? 0
                ),
                isBadgeUnlocked: isBadgeUnlocked,
                badgeMessage: badgeMessage.message,
                highlightedBadgeMessageText: badgeMessage.highlighted
            )
        }
    }
    
    private static func formatAmount(lowestRange: Int, highestRange: Int) -> String {
        let lowest = numberFormatter.string(from: .init(value: lowestRange))!
        let highest = numberFormatter.string(from: .init(value: highestRange))!
        
        return lowest + " - " + highest
    }
    
    private static func badgeMessage(isBadgeUnlocked: Bool, diffAmount: Int) -> (message: String, highlighted: String) {
        let diffAmountString = numberFormatter.string(from: .init(value: diffAmount))!
        let message = "Butuh " + diffAmountString + " untuk level up"
        
        return (isBadgeUnlocked ? "Semua orang bisa melihat badge ini" : message, diffAmountString)
    }
}
