//
//  EditAddressInteractor.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class EditAddressInteractor {
	
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	private let disposeBag = DisposeBag()
	let addressUseCase = Injection.init().provideAddressUseCase()
	let address: Address?
	let type: AddressTypeEnum!
	let isSeller: AddressFetchType!
	
	init(address: Address?, type: AddressTypeEnum, isSeller: AddressFetchType!) {
		self.address = address
		self.type = type
		self.isSeller = isSeller
	}
	
	func addAddress(address: Address) -> Observable<DefaultResponse> {
		return addressUseCase.addAddress(address: address)
	}
	
	func updateAddress(id: String, address: Address) -> Observable<DefaultResponse> {
		return addressUseCase.editAddress(id: id, address: address)
	}
	
	func removeAddress(id: String) -> Observable<RemoveResponse> {
		return addressUseCase.removeAddress(id: id)
	}
	

}

enum AddressTypeEnum : String {
	case edit = "edit"
	case add = "add"
}
