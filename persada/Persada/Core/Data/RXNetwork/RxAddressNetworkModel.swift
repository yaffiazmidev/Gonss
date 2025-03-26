//
//  RxAddressNetworkModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 10/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxAddressNetworkModel {
	
	private let network: Network<DefaultResponse>
	private let networkAddress: Network<AddressResult>
	private let networkAddressSingle: Network<SingleAddressResult>
	private let networkArea: Network<AreaResult>
	private let networkRemove: Network<RemoveResponse>
	private let networkPostalCode : Network<NewPostalCodeResult>
	
	
	init(network: Network<DefaultResponse>, networkAddress: Network<AddressResult>, networkAddressSingle: Network<SingleAddressResult>, networkArea: Network<AreaResult>, networkRemove: Network<RemoveResponse>, networkPostalCode: Network<NewPostalCodeResult>) {
		self.network = network
		self.networkAddress = networkAddress
		self.networkAddressSingle = networkAddressSingle
		self.networkArea = networkArea
		self.networkRemove = networkRemove
		self.networkPostalCode = networkPostalCode
	}
	
	func addAddress(address: Address) -> Observable<DefaultResponse> {
		let requestEndpoint = AddressEndpoint.createAddress(address: address)
		return network.postItemNew(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: requestEndpoint.header)
	}
	
	func fetchAddress(type: String) -> Observable<AddressResult> {
		let requestEndpoint = AddressEndpoint.address(type: type)
		return networkAddress.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func fetchAddressSingle() -> Observable<SingleAddressResult> {
		let requestEndpoint = AddressEndpoint.addressDelivery
		return networkAddressSingle.getItems(requestEndpoint.path)
	}
	
	func fetchProvince() -> Observable<AreaResult> {
		let requestEndpoint = AddressEndpoint.province
		return networkArea.getItems(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func fetchCity(id: String) -> Observable<AreaResult> {
		let requestEndpoint = AddressEndpoint.city(id: id)
		return networkArea.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func fetchSubdistrict(id: String) -> Observable<AreaResult> {
		let requestEndpoint = AddressEndpoint.subdistrict(id: id)
		return networkArea.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func fetchPostalCode(id: String) -> Observable<NewPostalCodeResult> {
		let requestEndpoint = AddressEndpoint.postalCode(id: id)
		return networkPostalCode.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func removeAddress(id: String) -> Observable<RemoveResponse> {
		let requestEndpoint = AddressEndpoint.removeAddress(id: id)
		return networkRemove.deleteItem(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: requestEndpoint.header)
	}
	
	func editAddress(id: String, address: Address) -> Observable<DefaultResponse> {
		let requestEndpoint = AddressEndpoint.editAddress(id: id, address: address)
		return network.putItem(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func searchAddressSeller(query: String) -> Observable<AddressResult> {
		let requestEndpoint = AddressEndpoint.searchAddressSeller(query: query)
		return networkAddress.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
	
	func searchAddressBuyer(query: String) -> Observable<AddressResult> {
		let requestEndpoint = AddressEndpoint.searchAddressBuyer(query: query)
		return networkAddress.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
	}
    
    func getAddressDelivery(accountID: String) -> Observable<SingleAddressResult> {
        let requestEndpoint = AddressEndpoint.getAddressDelivery(accountID: accountID)
        return networkAddressSingle.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
    }
    
}
