//
//  NotificationTransactionDetailViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 10/05/24.
//

import Foundation
import KipasKipasNotification

public protocol INotificationTransactionDetailViewModel {
    var transactionId: String { get set }
    func fetchDetail()
}

public protocol NotificationTransactionDetailViewModelDelegate: AnyObject {
    func displayTransactionDetail(with item: NotificationTransactionDetailItem)
    func displayError(with message: String)
}

public class NotificationTransactionDetailViewModel: INotificationTransactionDetailViewModel {
    
    public weak var delegate: NotificationTransactionDetailViewModelDelegate?
    
    private let loader: NotificationTransactionDetailLoader
    public var transactionId: String = ""
    
    public init(loader: NotificationTransactionDetailLoader) {
        self.loader = loader
    }
    
    public func fetchDetail() {
        loader.load(request: .init(id: transactionId)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayTransactionDetail(with: response)
            }
        }
    }
}
