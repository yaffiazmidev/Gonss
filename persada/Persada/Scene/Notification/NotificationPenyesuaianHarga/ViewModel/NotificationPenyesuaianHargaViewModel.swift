//
//  NotificationPenyesuaianHargaViewModel.swift
//  KipasKipas
//
//  Created by koanba on 02/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationPenyesuaianHargaViewModel {
    
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private let disposeBag = DisposeBag()
    private let usecase: NotificationUseCase
    private var id: String
    
    var isLoading = BehaviorRelay<Bool?>(value: nil)
    var product = BehaviorRelay<TransactionProduct?>(value: nil)
    var error = BehaviorRelay<String?>(value: "")
    
    init(id: String) {
        self.id = id
        self.usecase = Injection.init().provideNotificationUseCase()
    }
    
    func fetchData() {
        isLoading.accept(true)
        usecase.getDetailNotificationTransation(id: id)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { result in
                self.product.accept(result.data)
                self.isLoading.accept(false)
            }, onError: { error in
                self.mappingErrorRelay(error: error)
                self.isLoading.accept(false)
            }).disposed(by: disposeBag)
    }
    
    func mappingErrorRelay(error: Error) {
        if let apiError = error as? ErrorMessage {
            self.error.accept(apiError.statusData)
        } else {
            self.error.accept(error.localizedDescription)
        }
    }
    
}
