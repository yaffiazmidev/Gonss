//
//  KKNotificationContentSystemViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 26/04/24.
//

import Foundation
import KipasKipasNotification


protocol IKKNotificationContentSystemViewModel {
    var currentPage: Int { get set }
    var totalPage: Int { get set }
    var types: String { get set }
    
    func fetchNotification()
}

protocol KKNotificationContentSystemViewModelDelegate: AnyObject {
    func displayNotifications(with contents: [NotificationSystemContent])
    func displayError(with message: String)
}

class KKNotificationContentSystemViewModel: IKKNotificationContentSystemViewModel {
    
    public weak var delegate: KKNotificationContentSystemViewModelDelegate?
    private let systemNotifLoader: NotificationSystemLoader
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    var types: String = ""
    
    init(systemNotifLoader: NotificationSystemLoader) {
        self.systemNotifLoader = systemNotifLoader
    }
    
    func fetchNotification() {
        let request = NotificationSystemRequest(page: currentPage, size: 10, types: types)
        systemNotifLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.totalPage = (response.totalPages ?? 0) - 1
                self.delegate?.displayNotifications(with: response.content)
            }
        }
    }
}
