//
//  SearchNewsModel.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum SearchNewsModel {
	
	enum Request {
		case searchNews(by: String, page: Int)
		case searchNewsPaging(by: String, page: Int)
	}
	
	enum Response {
		case searchNews(NewsArray)
	}
	
	enum ViewModel {
		case news(viewModel: [NewsCellViewModel])
	}
	
	enum Route {
		case dismiss
	}
	
	class DataSource: DataSourceable {
		@Published var text: String = ""
		@Published var data: [NewsCellViewModel] = []
	}
}
