//
//  AnotherProductModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/06/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import Foundation

enum AnotherProductModel {
	
	enum Request {
	}
	
	enum Response {
		case products(ProductResult)
		case paginationProduct(ProductResult)
		case presentErrorResponse(data: ErrorMessage)
		case emptySearchProduct
	}
	
	enum ViewModel {
		case paginationProduct(viewModel: [Product])
		case listProductById(viewModel: [Product])
		case presentErrorResponse(data: ErrorMessage)
		case emptySearchProduct
		case checkTheAddress(address: [Address])
        case shopDataNotComplete
	}
	
	enum Route {
		case dismiss
		case selectedComment(id: String, dataSource: CommentHeaderCellViewModel)
		case showProfile(id: String, type: String)
		case report(id: String, accountId: String, imageUrl: String)
		case seeProduct(shop: Product, account: Profile?)
		case addAdress
	}
	
	struct DataSource: DataSourceable {
		var id: String?
		var paramReport: (id: String, accountId: String, imageUrl: String)?
		var isLoading: Bool? = false
		var statusLike: String?
		var index: Int?
		var page: Int?
		var showNavBar: Bool?
		var headerComment: CommentHeaderCellViewModel?
		var data: [Product]? = []
	}
}
