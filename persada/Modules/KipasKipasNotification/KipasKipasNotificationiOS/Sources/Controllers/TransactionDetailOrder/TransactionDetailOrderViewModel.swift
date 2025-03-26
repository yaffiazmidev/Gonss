//
//  TransactionDetailOrderViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import Foundation
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

public protocol ITransactionDetailOrderViewModel {
    var transactionId: String { get set }
    var orderId: String { get set }
    
    func fetchDetail()
    func fetchOrder()
}

public protocol TransactionDetailOrderViewModelDelegate: AnyObject {
    func displayDetail(with item: NotificationTransactionDetailItem)
    func displayOrder(with item: DonationTransactionDetailOrderItem)
    func displayErrorDetail(with message: String)
    func displayErrorOrder(with message: String)
}

public class TransactionDetailOrderViewModel: ITransactionDetailOrderViewModel {
    
    public weak var delegate: TransactionDetailOrderViewModelDelegate?
    
    private let loader: NotificationTransactionDetailLoader
    let orderLoader: DonationTransactionDetailOrderLoader
    
    public var transactionId: String = ""
    public var orderId: String = ""
    
    public init(
        loader: NotificationTransactionDetailLoader,
        orderLoader: DonationTransactionDetailOrderLoader
    ) {
        self.loader = loader
        self.orderLoader = orderLoader
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
}
