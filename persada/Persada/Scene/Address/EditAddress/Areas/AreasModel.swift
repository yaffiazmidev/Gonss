//
//  AreasModel.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum AreasModel {
	
	enum Request {
		case province
		case city(id: String)
		case subdistrict(id: String)
	}
	
	enum Response {
		case provinces(data: AreaResult)
		case citys(data: AreaResult)
		case subdistricts(data: AreaResult)
	}
	
	enum ViewModel {
		case proviences(viewModel: [Area])
		case citys(viewModel: [Area])
		case subdistricts(viewModel: [Area])
	}
	
	enum Route {
		case dismissAreasScene
		case dismiss(value: Area, type: String)
	}
	
	struct DataSource: DataSourceable {
		var data: [Area]?
		var type: String?
		var id: String?
	}
}
