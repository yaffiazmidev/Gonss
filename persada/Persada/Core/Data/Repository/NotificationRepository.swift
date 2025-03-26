//
//  NotificationRepository.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 03/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol NotificationRepository {
    func getNotificationSocial(page: Int, size: Int) -> Observable<NotificationSocialResult>
    func getNotificationTransaction(page: Int, size: Int) -> Observable<NotificationTransactionResult>
    func getDetailNotificationTransation(id: String) -> Observable<TransactionProductResult>
    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse>
}

class NotificationRepositoryImpl: NotificationRepository {
 
    fileprivate let remote: RxNotificationNetworkModel
    
    typealias NotificationInstance = (RxNotificationNetworkModel) -> NotificationRepository
    
    private init(remote: RxNotificationNetworkModel) {
        self.remote = remote
    }
    
    static let sharedInstance: NotificationInstance = {remoteRepo in
        return NotificationRepositoryImpl(remote: remoteRepo)
    }
    
    func getNotificationSocial(page: Int, size: Int) -> Observable<NotificationSocialResult> {
        return remote.fetchNotificationSocial(page: page, size: size)
    }
    
    func getNotificationTransaction(page: Int, size: Int) -> Observable<NotificationTransactionResult> {
        return remote.fetchNotificationTransaction(page: page, size: size)
    }
    
    func getDetailNotificationTransation(id: String) -> Observable<TransactionProductResult> {
        return remote.detailNotificationTransaction(id: id)
    }
    
    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse> {
        return remote.isReadNotification(type: type, id: id)
    }
}
