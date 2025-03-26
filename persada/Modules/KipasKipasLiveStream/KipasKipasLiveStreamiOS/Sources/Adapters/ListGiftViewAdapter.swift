import UIKit
import Combine
import KipasKipasLiveStream

protocol ListGiftAdapterDelegate: AnyObject {
    func didFinishRequestList(with gifts: [LiveGift])
    func didFinishRequestCoin(with coinBalance: Int)
}

final class ListGiftAdapter {
    
    private let listGiftLoader: () -> ListGiftLoader
    private let coinBalanceLoader: () -> LiveCoinBalanceLoader
    
    private var cancellables: Set<AnyCancellable> = []
    
    weak var delegate: ListGiftAdapterDelegate?
    
    init(
        listGiftLoader: @escaping () -> ListGiftLoader,
        coinBalanceLoader: @escaping () -> LiveCoinBalanceLoader
    ) {
        self.listGiftLoader = listGiftLoader
        self.coinBalanceLoader = coinBalanceLoader
    }
    
    func loadListGift() {
        listGiftLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.didFinishRequestList(with: [])
                }
            }, receiveValue: { [weak self] result in
                self?.delegate?.didFinishRequestList(with: result.data)
            })
            .store(in: &cancellables)
    }
    
    func loadCoinBalance() {
        coinBalanceLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.didFinishRequestCoin(with: 0)
                }
            }, receiveValue: { [weak self] result in
                self?.delegate?.didFinishRequestCoin(with: result.data.coin ?? 0)
            })
            .store(in: &cancellables)
    }
}
