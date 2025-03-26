//
//  AddressUseCase.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 10/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
protocol AddressUseCase {
	func getAddress(type: String) -> Observable<AddressResult>
	func getAddressSingle() -> Observable<SingleAddressResult>
	func fetchProvince() -> Observable<AreaResult>
	func fetchCity(id: String) -> Observable<AreaResult>
	func fetchSubdistrict(id: String) -> Observable<AreaResult>
	func fetchPostalCode(id: String) -> Observable<NewPostalCodeResult>
	func removeAddress(id: String) -> Observable<RemoveResponse>
	func editAddress(id: String, address: Address) -> Observable<DefaultResponse>
	func addAddress(address: Address) -> Observable<DefaultResponse>
	func searchAddressSeller(query: String) -> Observable<AddressResult>
	func searchAddressBuyer(query: String) -> Observable<AddressResult>
    func getAddressDelivery(accountID : String) -> Observable<SingleAddressResult>
}

class AddressInteractorRx: AddressUseCase {
  
    
	
	private let repository: AddressRepository
	
	required init(repository: AddressRepository) {
		self.repository = repository
	}
	
	func getAddress(type: String) -> Observable<AddressResult> {
		return repository.getAddress(type: type)
	}
	
	func getAddressSingle() -> Observable<SingleAddressResult> {
		return repository.getAddressSingle()
	}
	
	func fetchProvince() -> Observable<AreaResult> {
		return repository.getProvince()
	}
	
	func fetchCity(id: String) -> Observable<AreaResult> {
		return repository.getCity(id: id)
	}
	
	func fetchSubdistrict(id: String) -> Observable<AreaResult> {
		return repository.getSubdistrict(id: id)
	}
	
	func fetchPostalCode(id: String) -> Observable<NewPostalCodeResult> {
		return repository.getPostalCode(id: id)
	}
	
	func removeAddress(id: String) -> Observable<RemoveResponse> {
		return repository.removeAddress(id: id)
	}
	
	func editAddress(id: String, address: Address) -> Observable<DefaultResponse> {
		return repository.editAddress(id: id, address: address)
	}
	
	func addAddress(address: Address) -> Observable<DefaultResponse> {
		return repository.addAddress(address: address)
	}
	
	func searchAddressSeller(query: String) -> Observable<AddressResult> {
		return repository.searchAddressSeller(query: query)
	}
	
	func searchAddressBuyer(query: String) -> Observable<AddressResult> {
		return repository.searchAddressBuyer(query: query)
	}
    
    func getAddressDelivery(accountID : String) -> Observable<SingleAddressResult> {
        return repository.getAddressDelivery(accountID : accountID)
    }
	
}

