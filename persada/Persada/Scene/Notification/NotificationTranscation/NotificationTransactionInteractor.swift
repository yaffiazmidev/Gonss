//
//  NotificationTransactionInteractor.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class NotificationTransactionInteractor {

    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let disposeBag = DisposeBag()
    let notificationUseCase = Injection.init().provideNotificationUseCase()


    
    func notificationTransactionResponse(page: Int, size: Int) -> Observable<NotificationTransactionResult> {
        return notificationUseCase.getNotificationTransaction(page: page, size: size).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
    }

    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse> {
        return notificationUseCase.isReadNotification(type: type, id: id)
    }
}
