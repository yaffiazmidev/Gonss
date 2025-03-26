//
//  AddressPresenter.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - AddressPresentationLogic
final class AddressPresenter {
	
	let addressResult = BehaviorRelay<[Address]>(value: [])
	
	var didSelectRowTrigger = PublishSubject<Int>()
	let isEmpty = BehaviorRelay<Bool?>(value: nil)
	let isEmptySearch = BehaviorRelay<Bool?>(value: nil)
	let errorRelay = BehaviorRelay<Error?>(value: nil)
	
	lazy var searchValue : BehaviorRelay<String> = BehaviorRelay(value:"")

	lazy var searchValueObservable: Observable<String> = self.searchValue.asObservable()
	
	private let disposeBag = DisposeBag()
	private let router : AddressRouter!
	private let interactor = AddressInteractor()
    var type : BehaviorRelay<AddressFetchType> = BehaviorRelay<AddressFetchType>(value: .seller)
	
	init(router: AddressRouter, type: AddressFetchType) {
		self.router = router
        self.type.accept(type)
		
		
		didSelectRowTrigger.asObservable()
				.observeOn(MainScheduler.asyncInstance)
				.bind(onNext: selectRow)
				.disposed(by: disposeBag)
		
		fetchAddress()
		search()
	}
	
	func fetchAddress() {
        interactor.addressResponse(type: type.value.rawValue).subscribe { [weak self] (result) in
			let sorted = result.data?.sorted(by: { (add0, add1) -> Bool in
							add0.id ?? "" > add1.id ?? ""
						})
			self?.addressResult.accept(sorted ?? [])

			self?.isEmpty.accept(result.data?.isEmpty ?? nil)
		} onError: { [weak self] (error) in
			self?.errorRelay.accept(error)
		}.disposed(by: disposeBag)
	}
	
	func searchAddress(query: String) {
        switch type.value {
		case .buyer:
			interactor.searchAddressBuyer(query: query).subscribe { [weak self] (result) in
				self?.addressResult.accept(result.data ?? [])
				self?.isEmptySearch.accept(result.data?.isEmpty ?? true)
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		case .seller:
			interactor.searchAddressSeller(query: query).subscribe { [weak self] (result) in
				self?.addressResult.accept(result.data ?? [])
				self?.isEmpty.accept(result.data?.isEmpty ?? nil)
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		default:
			return
		}
	}
	

	private func selectRow(indexPath: Int) {
		let address = addressResult.value[indexPath]
        router.detailEditAddress(address, isSeller: type.value, addressResult.value.count > 1)
	}
	
    func routeToAddAddress(isCheckout : Bool){
        if addressResult.value.isEmpty {
            router.detailAddAddress(isSeller: type.value, isFirstAdded: true, isCheckout: isCheckout)
        } else {
            router.detailAddAddress(isSeller: type.value)
        }
	}
	
	func search(){
		searchValueObservable.asObservable().subscribe(onNext: { [weak self] value in
			self?.searchAddress(query: value)
		}).disposed(by: disposeBag)
	}
}


enum AddressFetchType : String {
	case buyer = "BUYER_ADDRESS"
	case seller = "SELLER_ADDRESS"
}

