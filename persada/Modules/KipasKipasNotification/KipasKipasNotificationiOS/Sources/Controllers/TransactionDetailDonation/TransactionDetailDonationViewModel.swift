//
//  TransactionDetailDonationViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

public protocol ITransactionDetailDonationViewModel {
    var transactionId: String { get set }
    var orderId: String { get set }
    var groupOrderId: String { get set }
    
    func fetchDetail()
    func fetchOrder()
    func fetchGroupOrder()
}

public protocol TransactionDetailDonationViewModelDelegate: AnyObject {
    func displayDetail(with item: NotificationTransactionDetailItem)
    func displayOrder(with item: DonationTransactionDetailOrderItem)
    func displayGroupOrder(with item: DonationTransactionDetailGroupItem)
    func displayErrorDetail(with message: String)
    func displayErrorOrder(with message: String)
    func displayErrorGroupOrder(with message: String)
}

public class TransactionDetailDonationViewModel: ITransactionDetailDonationViewModel {
    
    public weak var delegate: TransactionDetailDonationViewModelDelegate?
    
    private let loader: NotificationTransactionDetailLoader
    let orderLoader: DonationTransactionDetailOrderLoader
    let groupLoader: DonationTransactionDetailGroupLoader
    
    public var transactionId: String = ""
    public var orderId: String = ""
    public var groupOrderId: String = ""
    
    public init(
        loader: NotificationTransactionDetailLoader,
        orderLoader: DonationTransactionDetailOrderLoader,
        groupLoader: DonationTransactionDetailGroupLoader
    ) {
        self.loader = loader
        self.orderLoader = orderLoader
        self.groupLoader = groupLoader
    }
    
    public func fetchDetail() {
        loader.load(request: .init(id: transactionId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayErrorDetail(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayDetail(with: response)
            }
        }
    }
    
    public func fetchOrder() {
        orderLoader.load(request: .init(id: orderId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayErrorOrder(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayOrder(with: response)
            }
        }
    }
    
    public func fetchGroupOrder() {
        guard !groupOrderId.isEmpty else { return }
        groupLoader.load(request: .init(groupId: groupOrderId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayErrorGroupOrder(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayGroupOrder(with: response)
            }
        }
    }
}
