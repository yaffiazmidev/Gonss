import Foundation

public protocol DonationHistoryView {
    func display(_ viewModel: [DonationHistoryViewModel], isFirstLoad: Bool)
}

public protocol DonationHistoryLoadingView {
    func display(_ viewModel: DonationHistoryLoadingViewModel)
}

public protocol DonationHistoryPagingView {
    func display(_ viewModel: DonationHistoryPagingViewModel)
}

public final class DonationHistoryPresenter {
    
    private let view: DonationHistoryView
    private let loadingView: DonationHistoryLoadingView
    private let pagingView: DonationHistoryPagingView
    
    private static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "id-ID")
        return numberFormatter
    }()
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "id-ID")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 25200)
        return dateFormatter
    }()
    
    private var previousItems: [RemoteDonationHistory] = []
    
    public init(
        view: DonationHistoryView,
        loadingView: DonationHistoryLoadingView,
        pagingView: DonationHistoryPagingView
    ) {
        self.view = view
        self.loadingView = loadingView
        self.pagingView = pagingView
    }
    
    public func didStartLoading() {
        loadingView.display(.init(isLoading: true))
        pagingView.display(.init(isLoading: true, totalItems: 0))
    }
    
    public func didFinishLoad(with histories: [RemoteDonationHistory], isFirstLoad: Bool) {
        loadingView.display(.init(isLoading: false))
        pagingView.display(.init(isLoading: false, totalItems: histories.count))
        view.display(DonationHistoryPresenter.map(histories), isFirstLoad: isFirstLoad)
    }
    
    private static func map(_ histories: [RemoteDonationHistory]) -> [DonationHistoryViewModel] {
        return histories.map {
            return .init(
                id: $0.id ?? UUID().uuidString,
                accountName: $0.accountName ?? "Orang Dermawan",
                nominal: currencyFormatter($0.nominal ?? 0),
                bankFee: "Biaya Admin -" + currencyFormatter($0.bankFee ?? 0),
                createdAt: dateFormatter($0.createAt ?? 0), 
                type: .init(rawValue: $0.historyType ?? "") ?? .credit
            )
        }
    }
    
    private static func currencyFormatter(_ value: Double) -> String {
        return numberFormatter.string(from: .init(value: value))!
    }
    
    private static func dateFormatter(_ timestampInMilliseconds: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestampInMilliseconds / 1000))
        return dateFormatter.string(from: date)
    }
}
