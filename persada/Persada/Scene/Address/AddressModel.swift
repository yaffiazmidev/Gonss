//
//  AddressModel.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum AddressModel {
	
	enum Request {
		case getUserAddress
	}
	
	enum Response {
		case userAddress(data: AddressResult)
	}
	
	enum ViewModel {
		case address(viewModel: [Address])
	}
	
	enum Route {
		case detailEditAddress(data: Address)
		case detailAddAddress
		case dismissAddressScene
	}
	
	struct DataSource: DataSourceable {
		var data: [Address]?
	}
}
