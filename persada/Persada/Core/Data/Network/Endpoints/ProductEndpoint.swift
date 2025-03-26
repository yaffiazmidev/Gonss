//
//  ProductEndpoint.swift
//  KipasKipas
//
//  Created by movan on 06/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum ProductEndpoint: EndpointType {
	case listMyProduct(page: Int)
	case listProduct(page: Int)
    case listPublicProduct(page: Int)
    case staticProducts(page: Int)
	case deliveryAddress(id: String)
	case listProductById(page: Int, id: String)
	case searchListProductById(id: String, text: String)
    case searchListProductByIdWithPage(id: String, text: String, page: Int)
	case searchMyProducts(text: String)
    case searchMyProductsWithPage(text: String, page: Int)
    case searchPublicMyProducts(text: String)
	
	
	case deletedProductById(id: String)
	case updateProductById(id: String)
    case getProductById(id: String)
    case getPublicProductById(id: String)
    
    case getArchiveProduct
    case listArchiveProduct(page: Int)
    case searchArchiveProductBy(name: String)
    case activeArchiveProduct(active: Bool, id: String)
    case archiveProductById(id: String, status: String)
    case editProduct(_ product: Product)
    
    case deleteMediaById(idProduct: String, id: String)
    case addProduct(product: Product)
    case removeProductMedia(productID: String, mediaID: String)
}

extension ProductEndpoint {
	
	var path: String {
		switch self {
		case .listMyProduct(_):
			return "/products/me"
		case .listProduct(_):
			return "/products"
        case .listPublicProduct(_):
            return "/public/products"
        case .staticProducts:
            return "/statics/products"
		case .deliveryAddress(let id):
			return "/addresses/delivery/\(id)"
		case .listProductById(_, let id):
			return "/products/account/\(id)"
		case .searchListProductById(let id,_):
			return "/products/search/account/\(id)"
        case .searchListProductByIdWithPage(let id,_,_):
            return "/products/search/account/\(id)"
		case .searchMyProducts(_), .searchMyProductsWithPage(_, _):
			return "/products/search"
        case .searchPublicMyProducts(_):
            return "/public/products/search"
        case .archiveProductById, .activeArchiveProduct(_, _):
			return "/products/archive"
		case .listArchiveProduct:
			return "/products/list/archived"
		case .searchArchiveProductBy:
			return "/products/archive/search"
		case .deletedProductById(let id):
			return "/products/\(id)"
        case .deleteMediaById(let idProduct, let id):
            return "/products/\(idProduct)/medias/\(id)"
		case .updateProductById(let id):
			return "/products/\(id)"
        case .getProductById(id: let id):
               return "/products/\(id)"
        case .getPublicProductById(id: let id):
               return "/public/products/\(id)"
        case .getArchiveProduct:
            return "/products/list/archived"
        case .editProduct(let inProduct):
            return "/products/\(inProduct.id!)"
        case .addProduct:
            return "/products"
        case .removeProductMedia(let prodID, let mediaID):
            return "/products/\(prodID)/medias/\(mediaID)"
        }

	}
	
	var method: HTTPMethod {
		switch self {
        case .archiveProductById, .updateProductById, .editProduct, .activeArchiveProduct:
			return .put
        case .deletedProductById, .deleteMediaById:
			return .delete
        case .addProduct:
            return .post
		default:
			return .get
		}
	}
	
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var header: [String : Any] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
            "Content-Type": "application/json"
		]
	}
	
    var parameter: [String : Any] {
        switch self {
        case .listProduct(let page), .listPublicProduct(let page), .listMyProduct(let page), .listArchiveProduct(let page), .staticProducts(let page) :
            return [
                "page" : "\(page)",
                "size" : "10",
                "sort" : "createAt,desc"
            ]
        case .listProductById(let page,_):
            return [
                "Authorization" : "Bearer \(getToken() ?? "")",
                "page" : "\(page)",
                "size" : "10"
            ]
        case .searchListProductById(_, let text):
            return [
                "size" : "10",
                "name" : text
            ]
        case .searchListProductByIdWithPage(_, let text, let page):
            return [
                "size" : "10",
                "name" : text,
                "page" : page
            ]
        case .searchMyProducts(let name), .searchPublicMyProducts(let name), .searchArchiveProductBy(let name):
            return [
                "name" : name
            ]
            
        case .searchMyProductsWithPage(let name, let apge):
            return [
                "name" : name,
                "page" : apge
            ]
        case .archiveProductById(let id, let status):
            return [
                "id" : id,
                "status" : status
            ]
        case .activeArchiveProduct(let active, let id):
            return [
                "id" : id,
                "status" : active ? "active": "inactive"
            ]
        default:
            return [:]
        }
    }
	
	var body: [String : Any] {
        switch self {
        case .editProduct(let inProduct):
            return try! inProduct.asDictionary()
        case .addProduct(let product):
            return try! product.asDictionary()
        default:
            return [:]
        }
	}
}
