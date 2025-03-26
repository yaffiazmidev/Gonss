//
//  ProductDetailPresenter.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ProductDetailPresenter {
	private var router: ProductDetailRouter!
	
	var product: Product!
	var isActiveProduct: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
	private var productUsecase: ProductUseCase?
	var imagesRelay : BehaviorRelay<[Medias]> = BehaviorRelay<[Medias]>(value: [])
    var errorRelay : BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    let profileUsecase: ProfileUseCase?
    let addressUseCase = Injection.init().provideAddressUseCase()
    let productUseCase = Injection.init().provideProductUseCase()
    let _loadingState = BehaviorRelay<Bool>(value: false)
    var profileRelay: BehaviorRelay<Profile?> = BehaviorRelay<Profile?>(value: nil)
    
    private let disposeBag = DisposeBag()
    let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    
	init(router: ProductDetailRouter, product: Product?) {
		self.router = router
		self.product = product
		self.productUsecase = Injection.init().provideProductUseCase()
        self.profileUsecase = Injection.init().provideProfileUseCase()
		imagesRelay.accept(product?.medias ?? [])
		isItUser()
	}
	
	func isItUser(){
        if let id = product.originalAccountId {
            if id.isItUser()  {
                isActiveProduct.accept(true)
            } else if product.isDeleted == true || product.generalStatus == ProductStatusActivePage.inactive.rawValue {
                    isActiveProduct.accept(true)
            } else {
                isActiveProduct.accept(false)
            }
            getAccountNetwork(id: id)
        }
	}
	
	func configure(value: Product) {
		self.product = value
	}
    
    func getAccountNetwork(id: String) {
        profileUsecase?.getNetworkProfile(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                guard let account = result.data else {
                    return
                }
                self.profileRelay.accept(account)
            } onError: { err in
                self.errorRelay.accept(err.localizedDescription)
                if let error = err as? ErrorMessage, error.statusCode == 401 {
                    
                }
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
    
    func getDetailProduct(_ id: String, _ completion: @escaping ()->()){
        _loadingState.accept(true)
        productUsecase?.detailProduct(id: id)
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { result in
                guard let data = result.data else {
                    self.errorRelay.accept(.get(.productNotAvailableDesc))
                    return
                }
                
                self.product = data
                self.imagesRelay.accept(self.product?.medias ?? [])
                self.isItUser()
                if let id = data.id {
                    self.productYouHaveSeen(with: id)
                }
            } onError: { error in
                print("Error ger product detail \(error)")
                self.errorRelay.accept(.get(.productNotAvailableDesc))
            } onCompleted: {
                completion()
            }.disposed(by: disposeBag)
    }
    
    func getAddressDelivery(_ completion: @escaping (Address)->()){
        addressUseCase.getAddressDelivery(accountID: getIdUser())
            .subscribeOn(self.concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { (singleAddress) in
                print("Seller address \(singleAddress)")
                if let address = singleAddress.data {
                    completion(address)
                }
            } onError: { (err) in
                print("Error address \(err)")
                self.errorRelay.accept(err.localizedDescription)
            }.disposed(by: disposeBag)

    }
    
    func archiveProduct(productID : String, archive: Bool, onSuccessArchive: @escaping ()->()){
        productUsecase?.activeSearchProducts(archive, id: productID)
            .subscribe(onNext: { (result) in
                onSuccessArchive()
            }, onError: { (error) in
                self.errorRelay.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func deleteProduct(productID : String, onSuccessDelete: @escaping ()->()){
        productUsecase?.deleteProduct(by: productID)
            .subscribe(onNext: { (result) in
                onSuccessDelete()
            }, onError: { (error) in
                self.errorRelay.accept(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    func checkReseller(reseller: @escaping (_ follower: Bool, _ totalPost: Bool,_ shopDisplay: Bool) -> Void) {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<ResellerValidatorRoot?>(
            path: "products/reseller/validation",
            method: .get,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"]
        )
        
        service.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                print(error.message)
            case let .success(response):
                guard let validResponse = response, let validData = validResponse.data else { return }
               
                reseller(validData.follower ?? false, validData.totalPost ?? false, validData.shopDisplay ?? false)
            }
        }
    }
    
    func productYouHaveSeen(with id: String) {
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<DefaultResponse>(
            path: "products/\(id)/seen",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["type" : "ETALASE"]
        )
        
        service.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                print("PE-9838 gagal", error.getErrorMessage(), error.localizedDescription)
            case let .success(response):
                guard let message = response.message else { return }
                print("PE-9838 sukses", message)
            }
        }
    }
}
