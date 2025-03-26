//
//  KKNotificationSystemViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 26/04/24.
//

import Foundation
import KipasKipasNotification


protocol IKKNotificationSystemViewModel {
    var currentPage: Int { get set }
    var totalPage: Int { get set }
    
    func fetchAllNotification()
    func readNotification(by id: String, types: String)
    func readNotif()
    func fetchLottery()
}

protocol KKNotificationSystemViewModelDelegate: AnyObject {
    func displayNotifications(with contents: [NotificationSystemContent])
    func displayError(with message: String)
    func displayReadNotification(id: String, types: String)
}

class KKNotificationSystemViewModel: IKKNotificationSystemViewModel {
    
    
    public weak var delegate: KKNotificationSystemViewModelDelegate?
    private let systemNotifLoader: NotificationSystemLoader
    private let isReadChecker: NotificationSystemIsReadCheck
    private let readUpdater: NotificationReadUpdater
    private let lotteryLoader: NotificationLotteryLoader
    
    var currentPage: Int = 0
    var totalPage: Int = 0
    
    init(
        systemNotifLoader: NotificationSystemLoader,
        isReadChecker: NotificationSystemIsReadCheck,
        readUpdater: NotificationReadUpdater,
        lotteryLoader: NotificationLotteryLoader
    ) {
        self.systemNotifLoader = systemNotifLoader
        self.isReadChecker = isReadChecker
        self.readUpdater = readUpdater
        self.lotteryLoader = lotteryLoader
    }
    
    func fetchAllNotification() {
        let request = NotificationSystemRequest(page: currentPage, size: 10, types: "all")
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
    
    func readNotification(by id: String, types: String) {
        isReadChecker.check(request: .init(isRead: true, id: id)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
//                self.delegate?.displayError(with: error.localizedDescription)
                self.delegate?.displayReadNotification(id: id, types: types)
                print(error.localizedDescription)
            case .success(let response):
                self.delegate?.displayReadNotification(id: id, types: types)
                print(response)
            }
        }
    }
    
    public func readNotif() {
        readUpdater.update(.init(type: .systemNotif)) { result in
            switch result {
            case let .failure(error):
                print("Failed read systemNotif notification with error: \(error.localizedDescription)")
            case .success(_):
                print("Success read systemNotif notification..")
                NotificationCenter.default.post(name: Notification.Name("com.kipaskipas.updateNotificationCounterBadge"), object: nil)
            }
        }
    }
    
    func fetchLottery() {
        let request = NotificationLotteryRequest(page: currentPage)
        lotteryLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.totalPage = (response.totalPages) - 1
                let items = response.content.compactMap({
                    NotificationSystemContent(
                        id: $0.id,
                        types: $0.actionType,
                        title: $0.title,
                        subTitle: $0.actionMessage,
                        targetId: $0.targetId
                    )
                })
                self.delegate?.displayNotifications(with: items)
            }
        }
    }
}
