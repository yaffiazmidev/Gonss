import UIKit
import Combine
import KipasKipasLiveStream
import KipasKipasShared

protocol LiveStreamAudienceListAdapterDelegate: AnyObject {
    func didFinishRequest(with audiences: [LiveStreamAudience])
    func didFinishRequestTopSeats(with topSeats: [LiveTopSeat])
    func didFinishRequestClassicGift(with gifts: [LiveGift])
    func didFinishRequestCoin(with coinBalance: Int)
}

#warning("[BEKA] separate delegate and method to different class")
final class LiveStreamAudienceListAdapter {
    private let coinBalanceLoader: () -> LiveCoinBalanceLoader 
    private let classicGiftLoader: () -> ListGiftLoader
    private let listAudienceLoader: (LiveStreamAudienceListRequest) -> ListAudienceLoader
    private let topSeatsLoader: (String) -> LiveTopSeatLoader
    
    private var cancellables: Set<AnyCancellable> = []
        
    private var schedulerCancellable: AnyCancellable?
    
    weak var delegate: LiveStreamAudienceListAdapterDelegate?
    
    init(
        classicGiftLoader: @escaping () -> ListGiftLoader,
        listAudienceLoader: @escaping (LiveStreamAudienceListRequest) -> ListAudienceLoader,
        topSeatsLoader: @escaping (String) -> LiveTopSeatLoader,
        coinBalanceLoader: @escaping () -> LiveCoinBalanceLoader
    ) {
        self.classicGiftLoader = classicGiftLoader
        self.listAudienceLoader = listAudienceLoader
        self.topSeatsLoader = topSeatsLoader
        self.coinBalanceLoader = coinBalanceLoader
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
    
    func loadClassicGift() {
        classicGiftLoader()
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.didFinishRequestClassicGift(with: [])
                }
            }, receiveValue: { [weak self] result in
                self?.delegate?.didFinishRequestClassicGift(with: result.data)
            })
            .store(in: &cancellables)
    }
    
    func loadAudienceList(request: LiveStreamAudienceListRequest) {
        listAudienceLoader(request)
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.didFinishRequest(with: [])
                }
            }, receiveValue: { [weak self] audiences in
                self?.delegate?.didFinishRequest(with: audiences.data)
            })
            .store(in: &cancellables)
    }
    
    func loadTopSeats(every interval: TimeInterval, roomId: String) {
        let scheduler = Timer.publish(
            every: interval,
            on: .main,
            in: .default
        )
            .autoconnect()
            .setFailureType(to: Error.self)
        
        schedulerCancellable = scheduler
            .dispatchOnMainQueue()
            .flatMap({ _ in
                self.topSeatsLoader(roomId)
            })
            .sink(receiveCompletion: { [weak self] result in
                if case .failure = result {
                    self?.delegate?.didFinishRequestTopSeats(with: [])
                }
            }, receiveValue: { [weak self] topSeats in
                self?.delegate?.didFinishRequestTopSeats(with: topSeats.data) 
            })
        //Resolve into immediate immediate data
        self.topSeatsLoader(roomId).sink(receiveCompletion: { [weak self] result in
            if case .failure = result {
                self?.delegate?.didFinishRequestTopSeats(with: [])
            }
        }, receiveValue: { [weak self] topSeats in
            self?.delegate?.didFinishRequestTopSeats(with: topSeats.data)
        })
    }
    
    func cancel() {
        schedulerCancellable?.cancel()
        schedulerCancellable = nil
    }
}
