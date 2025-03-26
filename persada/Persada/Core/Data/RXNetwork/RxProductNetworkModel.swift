//
//  RxProductNetworkModel.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxProductNetworkModel {
	private let network: Network<ProductResult>
	private let networkArchive: Network<ProductResultById>
	private let networkDefault: Network<DefaultResponse>
    private let networkDelete: Network<DeleteResponse>
    private let networkDetail: Network<ProductDetailResult> = Network<ProductDetailResult>()
	
    init(network: Network<ProductResult>, networkArchive: Network<ProductResultById>, networkDefault: Network<DefaultResponse>, networkDelete: Network<DeleteResponse>) {
		self.network = network
		self.networkArchive = networkArchive
		self.networkDefault = networkDefault
        self.networkDelete = networkDelete
	}
	
	func fetchProduct(page: Int) -> Observable<ProductResult> {
        let endpoint = AUTH.isLogin()
        ? ProductEndpoint.listProduct(page: page)
        : ProductEndpoint.listPublicProduct(page: page)
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
	
    func fetchMyProducts(name: String = "", page: Int) -> Observable<ProductResult> {
		let endpoint = ProductEndpoint.listMyProduct(page: page)
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
	
	func fetchProductById(by id: String, page: Int) -> Observable<ProductResult> {
		let endpoint = ProductEndpoint.listProductById(page: page, id: id)
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
	
    func fetchArchiveProducts(page: Int) ->Observable<ProductResult> {
        let endpoint = ProductEndpoint.listArchiveProduct(page: page)
        return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
    
    func activeSearchProducts(_ active: Bool, id: String) -> Observable<ProductDetailResult> {
        let endpoint = ProductEndpoint.activeArchiveProduct(active: active, id: id)
        return networkDetail.updateItemWithURLParam(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header  as! [String: String], method: endpoint.method)
//        return networkDetail.updateItemPut(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
	
	func searchProducts(id: String, text: String) -> Observable<ProductResult> {
		let endpoint = ProductEndpoint.searchListProductById(id: id, text: text)
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
    
    func searchProductsPage(id: String, text: String, page: Int) -> Observable<ProductResult> {
        let endpoint = ProductEndpoint.searchListProductByIdWithPage(id: id, text: text, page: page)
        return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
	
	func searchProducts(by name: String) -> Observable<ProductResult> {
        let endpoint = AUTH.isLogin()
        ? ProductEndpoint.searchMyProducts(text: name)
        : ProductEndpoint.searchPublicMyProducts(text: name)
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
	}
    
    func searchMyProductWithPage(name: String, page: Int) -> Observable<ProductResult> {
        let endpoint = ProductEndpoint.searchMyProductsWithPage(text: name, page: page)
        return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
	
	func archiveProduct(_ request: ProductEndpoint) -> Observable<ProductResultById> {
		return networkArchive.putItem(request)
	}
	
	func searchArchiveProduct(by name: String) -> Observable<ProductResult> {
		let endpoint = ProductEndpoint.searchArchiveProductBy(name: name)
		let header = endpoint.header as! [String: String]
		return network.getItem(endpoint.path, parameters: endpoint.parameter, headers: header)
	}
	
	func deletedProduct(by id: String) -> Observable<DeleteResponse> {
		let endpoint = ProductEndpoint.deletedProductById(id: id)
		let header = endpoint.header as! [String: String]
		return networkDelete.deleteItem(endpoint.path, parameters: endpoint.parameter, headers: header )
	}
    
    func deleteMedia(by idProduct: String, id: String) -> Observable<DeleteResponse> {
        let endpoint = ProductEndpoint.deleteMediaById(idProduct: idProduct, id: id)
        let header = endpoint.header as! [String: String]
        return networkDelete.deleteItem(endpoint.path, parameters: endpoint.parameter, headers: header)
    }
	
	func updateProduct(_ request: ProductEndpoint) -> Observable<ProductResultById> {
		return networkArchive.putItem(request)
	}
    
    func detailProduct(id: String) -> Observable<ProductDetailResult> {
        let endpoint = AUTH.isLogin()
        ? ProductEndpoint.getProductById(id: id)
        : ProductEndpoint.getPublicProductById(id: id)
        return networkDetail.getItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
    
    func editProduct(_ product: Product) -> Observable<ProductDetailResult> {
        let endpoint = ProductEndpoint.editProduct(product)
        return networkDetail.putItem(endpoint)
    }
    
    func addProduct(product: Product) -> Observable<ProductDetailResult> {
        let endpoint = ProductEndpoint.addProduct(product: product)
        
        let validBody: Data = try! JSONEncoder().encode(product)
        return networkDetail.postItemNew(endpoint, body: validBody)
    }
    
    func removeProductMedia(productID: String, mediaID: String) -> Observable<DefaultResponse> {
        let endpoint = ProductEndpoint.removeProductMedia(productID: productID, mediaID: mediaID)
        return networkDefault.deleteItem(endpoint.path, parameters: endpoint.parameter, headers: endpoint.header as! [String: String])
    }
}
