//
//  NotificationUseCase.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 03/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol NotificationUseCase {
    func getNotificationSocial(page: Int, size: Int) -> Observable<NotificationSocialResult>
    func getNotificationTransaction(page: Int, size: Int) -> Observable<NotificationTransactionResult>
    func getDetailNotificationTransation(id: String) -> Observable<TransactionProductResult>
    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse>
}

class NotificationInteractorRx: NotificationUseCase {

    private let repository: NotificationRepository

    required init(repository: NotificationRepository) {
        self.repository = repository
    }

    func getNotificationSocial(page: Int, size: Int) -> Observable<NotificationSocialResult> {
        return repository.getNotificationSocial(page: page, size: size)
    }
    
    func getNotificationTransaction(page: Int, size: Int) -> Observable<NotificationTransactionResult> {
        return repository.getNotificationTransaction(page: page, size: size)
    }
    
    func getDetailNotificationTransation(id: String) -> Observable<TransactionProductResult> {
        return repository.getDetailNotificationTransation(id: id)
    }
    
    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse> {
        return repository.isReadNotification(type: type, id: id)
    }
    
}

