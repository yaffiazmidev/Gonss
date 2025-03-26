//
//  NotificationBannedInteractor.swift
//  KipasKipas
//
//  Created by koanba on 08/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationBannedInteractor {
    
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let disposeBag = DisposeBag()
    private let usecase: ProductUseCase
    
    init() {
        self.usecase = Injection.init().provideProductUseCase()
    }
    
    func detailNotificationTransaction(id: String) -> Observable<ProductDetailResult> {
        return usecase.detailProduct(id: id).subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
    }
    
}
