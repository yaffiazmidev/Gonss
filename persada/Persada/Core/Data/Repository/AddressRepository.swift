//
//  AddressRepository.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 10/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol AddressRepository {
	func getAddress(type: String) -> Observable<AddressResult>
	func getAddressSingle() -> Observable<SingleAddressResult>
	func getProvince() -> Observable<AreaResult>
	func getCity(id: String) -> Observable<AreaResult>
	func getSubdistrict(id: String) -> Observable<AreaResult>
	func getPostalCode(id: String) -> Observable<NewPostalCodeResult>
	func removeAddress(id: String) -> Observable<RemoveResponse>
	func editAddress(id: String, address: Address) -> Observable<DefaultResponse>
	func addAddress(address: Address) -> Observable<DefaultResponse>
	func searchAddressSeller(query: String) -> Observable<AddressResult>
	func searchAddressBuyer(query: String) -> Observable<AddressResult>
    func getAddressDelivery(accountID : String) -> Observable<SingleAddressResult>
}

class AddressRepositoryImpl: AddressRepository {
   
	fileprivate let remote: RxAddressNetworkModel
		 
	typealias AddressInstance = (RxAddressNetworkModel) -> AddressRepository
		 
	private init(remote: RxAddressNetworkModel) {
			self.remote = remote
	}
	
	static let sharedInstance: AddressInstance = {remoteRepo in
			return AddressRepositoryImpl(remote: remoteRepo)
	}
	
	func getAddress(type: String) -> Observable<AddressResult> {
		return remote.fetchAddress(type: type)
	}
	
	func getAddressSingle() -> Observable<SingleAddressResult> {
		return remote.fetchAddressSingle()
	}
	
	func getProvince() -> Observable<AreaResult> {
		return remote.fetchProvince()
	}
	
	func getCity(id: String) -> Observable<AreaResult> {
		return remote.fetchCity(id: id)
	}
	
	func getSubdistrict(id: String) -> Observable<AreaResult> {
		return remote.fetchSubdistrict(id: id)
	}
	
	func getPostalCode(id: String) -> Observable<NewPostalCodeResult> {
		return remote.fetchPostalCode(id: id)
	}
	
	func removeAddress(id: String) -> Observable<RemoveResponse> {
		return remote.removeAddress(id: id)
	}
	
	func editAddress(id: String, address: Address) -> Observable<DefaultResponse> {
		return remote.editAddress(id: id, address: address)
	}
	
	func addAddress(address: Address) -> Observable<DefaultResponse> {
		return remote.addAddress(address: address)
	}
	
	func searchAddressBuyer(query: String) -> Observable<AddressResult> {
		return remote.searchAddressBuyer(query: query)
	}
	
	func searchAddressSeller(query: String) -> Observable<AddressResult> {
		return remote.searchAddressSeller(query: query)
	}
    
    func getAddressDelivery(accountID: String) -> Observable<SingleAddressResult> {
        return remote.getAddressDelivery(accountID: accountID)
    }
    
	
}
