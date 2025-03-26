//
//  ProductArchivePresenter.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol ProductArchivePresentationLogic {
    func presentResponse(_ response: ProductArchiveModel.Response)
}

final class ProductArchivePresenter: Presentable {
    private weak var viewController: ProductArchiveDisplayLogic?
    private let disposeBag = DisposeBag()
    private let usecase: ProductUseCase
		let _errorMessage = BehaviorRelay<String?>(value: nil)
    
    let productsDataSource: BehaviorRelay<[Product]> = BehaviorRelay<[Product]>(value: [])
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

    var lastPage: Int = 0
    var requestedPage: Int = 0
    //var counterProduct: Int = 0
    //var isDataEmpty: Bool = false
    
    let _loadingState = BehaviorRelay<Bool>(value: false)
    var loadingState: Driver<Bool> {
        return _loadingState.asDriver()
    }
    
    init(_ viewController: ProductArchiveDisplayLogic?) {
        self.viewController = viewController
        self.usecase = Injection.init().provideProductUseCase()
    }
    
    func archiveProduct(productID : String, archive: Bool, onSuccessArchive: @escaping ()->()){
        usecase.activeSearchProducts(archive, id: productID)
            .subscribe(onNext: { (result) in
                onSuccessArchive()
            }, onError: { (error) in
                self._errorMessage.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteProduct(productID : String, onSuccessDelete: @escaping ()->()){
        usecase.deleteProduct(by: productID)
            .subscribe(onNext: { (result) in
                onSuccessDelete()
            }, onError: { (error) in
                self._errorMessage.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }

    func getNetworkProductArchive() {
        _loadingState.accept(true)
        usecase.getNetworkArchiveProducts(page: requestedPage)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                self._loadingState.accept(false)
                if result.code == "1000" {
                    
                    if result.data?.content?.count != 0 {
                        if self.requestedPage == 0 {
                            self.presentResponse(.archiveProduct(data: result.data?.content ?? []))
                        } else {
                            self.presentResponse(.pagination(data: result.data?.content ?? []))
                        }
                    } else {
                        self.presentResponse(.emptyArchiveProduct)
                    }
                    
                    self.requestedPage += 1
                }
            } onError: { error in
                self._errorMessage.accept(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    func searchArchiveProducts(searchingText: String) {
        _loadingState.accept(true)
        usecase.searchArchiveProducts(text: searchingText)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                self._loadingState.accept(false)
                if result.code == "1000" {
                    if result.data?.content?.count != 0 {
                        self.presentResponse(.archiveProduct(data: result.data?.content ?? []))
                    } else {
                        self.presentResponse(.emptyArchiveProduct)
                    }
                }
            } onError: { error in
                self._errorMessage.accept(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func activeSearchProducts(_ active: Bool, id: String) {
        _loadingState.accept(true)
        usecase.activeSearchProducts(active, id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { activeResult in
                if activeResult.code == "1000" {
                    self.presentResponse(.deleteProduct(data: activeResult.data!))
                }
            } onError: { error in
                self._errorMessage.accept(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}

// MARK: - ProductPresentationLogic
extension ProductArchivePresenter: ProductArchivePresentationLogic {
    func presentResponse(_ response: ProductArchiveModel.Response) {
        switch response {
        case .archiveProduct(let data):
           presentingProduct(data)
        case .emptyArchiveProduct:
            presentingEmpty()
        case .notFoundArchiveProduct:
            presentingNotFound()
        case .deleteProduct(let data):
            presentingDeleteProduct(data)
        case .pagination(data: let data):
            presentingPaginationArchiveProduct(data)
        }
    }
}

// MARK: - Private Zone
private extension ProductArchivePresenter {
    func presentingProduct(_ result: [Product]?) {
        
        guard let validData = result else {
            return
        }
        
        viewController?.displayViewModel(.product(viewModel: validData))
    }
    
    func presentingEmpty() {
        viewController?.displayViewModel(.empty)
    }
    
    func presentingNotFound() {
        viewController?.displayViewModel(.notFound)
    }
    
    func presentingDeleteProduct(_ product: Product) {
        viewController?.displayViewModel(.delete(id: product.id!))
    }
    
    func presentingPaginationArchiveProduct(_ result: [Product]?) {
            
            guard let validData = result else {
                return
            }
            
            viewController?.displayViewModel(.pagination(viewModel: validData))
    }
}

