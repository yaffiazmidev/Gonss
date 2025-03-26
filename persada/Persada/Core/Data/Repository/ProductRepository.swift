//
//  ProductRepository.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol ProductRepository {
	func getProductsNetwork(page: Int) -> Observable<ProductResult>
	func searchProducts(by text: String) -> Observable<ProductResult>
    func searchArchiveProducts(by text: String) -> Observable<ProductResult>
	func searchMyProducts(id: String, text: String) -> Observable<ProductResult>
	func getMyProducts(page: Int) -> Observable<ProductResult>
    func getProductDetail(_ id: String) -> Observable<ProductDetailResult>
    func getNetworkArchiveProducts(page: Int) -> Observable<ProductResult>
    func activeSearchProducts(_ active: Bool, id: String) -> Observable<ProductDetailResult>
	func getProductsById(by id: String, page: Int) -> Observable<ProductResult>
    func searchMyProductWithPage(text: String, page: Int) -> Observable<ProductResult>
    func searchProductWithPage(userid: String, text: String, page: Int) -> Observable<ProductResult>
    func deleteProductNetwork(id: String) -> Observable<DeleteResponse>
    func editProduct(_ product: Product) -> Observable<ProductDetailResult>
    
    func deleteMedia(by idProduct: String, id: String) -> Observable<DeleteResponse>
    func addProduct(product: Product) -> Observable<ProductDetailResult>
    func removeProductMedia(productID: String, mediaID: String) -> Observable<DefaultResponse>
}

final class ProductRepositoryImpl: ProductRepository {
    
	typealias ProductInstance = ( RxProductNetworkModel) -> ProductRepository
	
	fileprivate let remote: RxProductNetworkModel
	
	private init( remote: RxProductNetworkModel) {
		self.remote = remote
	}
	
	static let sharedInstance: ProductInstance = { remote in
		return ProductRepositoryImpl( remote: remote)
	}
    
    func deleteProductNetwork(id: String) -> Observable<DeleteResponse> {
        return remote.deletedProduct(by: id)
    }
	
	func searchProducts(by text: String) -> Observable<ProductResult> {
		return remote.searchProducts(by: text)
	}
    
    func searchArchiveProducts(by text: String) -> Observable<ProductResult> {
        return remote.searchArchiveProduct(by: text)
    }
	
    func activeSearchProducts(_ active: Bool, id: String) -> Observable<ProductDetailResult> {
        return remote.activeSearchProducts(active, id: id)
    }
	
	func getProductsNetwork(page: Int) -> Observable<ProductResult> {
		return remote.fetchProduct(page: page)
	}
	
	func searchMyProducts(id: String, text: String) -> Observable<ProductResult> {
		return remote.searchProducts(id: id, text: text)
	}
    
    func searchMyProductWithPage(text: String, page: Int) -> Observable<ProductResult> {
        return remote.searchMyProductWithPage(name: text, page: page)
    }
	
	func getMyProducts(page: Int) -> Observable<ProductResult> {
		return remote.fetchMyProducts(page: page)
	}
    
    func getNetworkArchiveProducts(page: Int) -> Observable<ProductResult> {
        return remote.fetchArchiveProducts(page: page)
    }
    
    func getProductDetail(_ id: String) -> Observable<ProductDetailResult> {
        return remote.detailProduct(id: id)
    }
	
	func getProductsById(by id: String, page: Int) -> Observable<ProductResult> {
		return remote.fetchProductById(by: id, page: page)
	}
    
    func searchProductWithPage(userid: String, text: String, page: Int) -> Observable<ProductResult> {
        return remote.searchProductsPage(id: userid, text: text, page: page)
	}
	
    func editProduct(_ product: Product) -> Observable<ProductDetailResult> {
        return remote.editProduct(product)
    }
    
    func deleteMedia(by idProduct: String, id: String) -> Observable<DeleteResponse> {
        return remote.deleteMedia(by: idProduct, id: id)
    }
    
    func addProduct(product: Product) -> Observable<ProductDetailResult> {
        return remote.addProduct(product: product)
    }
    
    func removeProductMedia(productID: String, mediaID: String) -> Observable<DefaultResponse> {
        return remote.removeProductMedia(productID: productID, mediaID: mediaID)
    }
}
