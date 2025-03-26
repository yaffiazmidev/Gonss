//
//  MyStoreSettingPresenter.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol  MyStoreSettingPresentationLogic {
}


final class MyStoreSettingPresenter: Presentable {
    private weak var viewController: MyStoreSettingDisplayLogic?
    private let addressUsecase = Injection.init().provideAddressUseCase()
    private let productUsecase = Injection.init().provideProductUseCase()
    private let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
    init(_ viewController: MyStoreSettingDisplayLogic?) {
        self.viewController = viewController
    }
    
    private let _errorMessage = BehaviorRelay<String?>(value: nil)
    var errorMessage: Driver<String?> {
        return _errorMessage.asDriver()
    }
    
    let _loadingState = BehaviorRelay<Bool>(value: false)
    var loadingState: Driver<Bool> {
        return _loadingState.asDriver()
    }
    
    let productsRelay = BehaviorRelay<[Product]>(value: [])
    
	func fetchAddressDelivery(addressFound: @escaping ()->(), addressNotFound: @escaping ()->()){
        addressUsecase.getAddressDelivery(accountID: getIdUser())
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { (address) in
                if address.data != nil {
                    addressFound()
                }
            } onError: { (error) in
							addressNotFound()
                print(error.localizedDescription)
            }.disposed(by: disposeBag)

    }
    
    func fetchProducts() {
        productUsecase.getNetworkArchiveProducts(page: 0)
                .subscribeOn(concurrentBackground)
                .observeOn(MainScheduler.instance)
                .subscribe { (result) in
                    guard let code = result.code, code == "1000" else {
                        self.productsRelay.accept([])
                        return
                    }
                    self.productsRelay.accept(result.data?.content ?? [])
                } onError: { (error) in
                    self.productsRelay.accept([])
                }.disposed(by: disposeBag)
        
        productUsecase.getMyProducts(page: 0)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { (result) in
                guard let code = result.code, code == "1000" else {
                    self.productsRelay.accept([])
                    return
                }
                self.productsRelay.accept(result.data?.content ?? [])
            } onError: { (error) in
                self.productsRelay.accept([])
            }.disposed(by: disposeBag)
    }
}

// MARK: - MyStoreSettingPresentationLogic
extension MyStoreSettingPresenter: MyStoreSettingPresentationLogic {

}


