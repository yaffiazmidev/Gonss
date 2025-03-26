//
//  EditAddressModel.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum EditAddressModel {
	
	enum Request {
		case saveAddress(id: String, parameter: Address)
		case addAddress(parameter: ParameterAddress)
		case addAddressSeller(parameter: ParameterAddress)
		case removeAddress(id: String)
	}
	
	enum Response {
		case save(DefaultResponse)
		case add(DefaultResponse)
		case remove(RemoveResponse)
	}
	
	enum ViewModel {
		case save(viewModel: DefaultResponse)
		case add(viewModel: DefaultResponse)
		case remove(viewModel: RemoveResponse)
	}
	
	enum Route {
		case dismissEditAddressScene
		case chooseProvince(type: String)
		case chooseCity(id: String, type: String)
		case chooseSubdistrict(id: String, type: String)
	}
	
	struct DataSource: DataSourceable {
		var data: Address?
		var parameter: ParameterAddress?
		var type: String?
		var isSellerAddress: Bool?
	}
}
