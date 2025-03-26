//
//  ProductModel.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

enum ProductModel {
	
	enum Request {
		case listProduct(isPagination: Bool)
		case listProductById(isPagination: Bool, id: String)
		case searchListProduct(id: String, searchText: String)
	}

	enum Response {
		case products(ProductResult)
		case paginationProduct(ProductResult)
		case presentErrorResponse(data: ErrorMessage)
        case emptySearchProduct
        case editProduct
        case addProduct
        case responseMedia([Medias])
        case deletMedia
	}

	enum ViewModel {
		case product(viewModel: [Product])
		case paginationProduct(viewModel: [Product])
		case listProductById(viewModel: [Product])
		case presentErrorResponse(data: ErrorMessage)
		case emptySearchProduct
		case checkTheAddress(address: [Address])
        case productDetail
        case media(viewModel: [Medias])
        case deleteMedia
        case addProduct
	}

	enum Route {
		case dismissProduct
		case selectedComment(id: String, dataSource: CommentHeaderCellViewModel)
		case showProfile(id: String, type: String)
		case report(id: String, accountId: String, imageUrl: String)
		case visitStore
		case seeProduct(shop: Product)
		case addAdress
		case addProduct
        case showQR
	}

	struct DataSource: DataSourceable {
		var id: String?
		var paramReport: (id: String, accountId: String, imageUrl: String)?
		var isLoading: Bool? = false
		var statusLike: String?
		var index: Int?
		var page: Int?
		var headerComment: CommentHeaderCellViewModel?
		var data: [Product]? = []
		
		mutating func setLoadingToggle() {
			isLoading?.toggle()
		}
	}
}
