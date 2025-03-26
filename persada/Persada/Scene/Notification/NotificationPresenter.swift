//
//  NotificationPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 18/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class NotificationPresenter {
    
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let disposeBag = DisposeBag()
    let notificationUseCase = Injection.init().provideNotificationUseCase()
    let notificationTransactionResult = BehaviorRelay<[NotificationTransaction]>(value: [])
    let notificationSocialResult = BehaviorRelay<[NotificationSocial]>(value: [])

    func notificationTransactionResponse(page: Int, size: Int) {
        // PE-13955
        guard getToken() != nil else { return }
        
        notificationUseCase.getNotificationTransaction(page: page, size: size)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.init())
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                if let data = result.data {
                    self.notificationTransactionResult.accept(data.content! )
                    
                    let totalNotifIsRead = self.notificationTransactionResult.value.filter { $0.isRead == false }.count
                    NotificationCenter.default.post(name: .notifyUpdateCounterTransaction, object: ["NotifyUpdateCounterTransaction" : Tampung(page: page, size: totalNotifIsRead)])
                }
            } onError: { err in
            } onCompleted: {
            }.disposed(by: disposeBag)

    }
    
    func notificationSocialResponse(page: Int, size: Int) {
        // PE-13955
        guard getToken() != nil else { return }
        
        notificationUseCase.getNotificationSocial(page: page, size: size)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.init())
            .subscribe { [weak self] result in
                guard let self = self else { return }
                if let data = result.data {
                    self.notificationSocialResult.accept(data.content! )
                    
                    let totalNotifIsRead = self.notificationSocialResult.value.filter { $0.isRead == false }.count
                    NotificationCenter.default.post(name: .notifyUpdateCounterSocial, object: ["NotifyUpdateCounterSocial" : Tampung(page: page, size: totalNotifIsRead)])
                }
            } onError: { err in
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}
