//
//  VirtualAccountNumberModel.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum VirtualAccountNumberModel {
	
	enum Request {
		
	}
	
	enum Response {
		
	}
	
	enum ViewModel {
		
	}
	
	enum Route {
		case dismissVirtualAccountNumberScene
	}
	
	struct DataSource: DataSourceable {
		var bankName : String?
		var bankNumber : String?
		var time : Int?
	}
}
