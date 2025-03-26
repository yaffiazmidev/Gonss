//
//  ProductUseCase.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol ProductUseCase: AnyObject {
	func getNetworkProducts(page: Int) -> Observable<ProductResult>
	func searchProducts(id: String, text: String) -> Observable<ProductResult>
	func searchProducts(text: String) -> Observable<ProductResult>
	func getMyProducts(page: Int) -> Observable<ProductResult>
    func detailProduct(id: String) -> Observable<ProductDetailResult>
    func getNetworkArchiveProducts(page: Int) -> Observable<ProductResult>
    func searchArchiveProducts(text: String) -> Observable<ProductResult>
    func activeSearchProducts(_ active: Bool, id: String) -> Observable<ProductDetailResult>
	func getProducts(by id: String, page: Int) -> Observable<ProductResult>
    
    func deleteProduct(by id: String) -> Observable<DeleteResponse>
    func editProduct(_ product: Product) -> Observable<ProductDetailResult>
    
    func deleteMedia(by idProduct: String, id: String) -> Observable<DeleteResponse>
    func addProduct(product: Product) -> Observable<ProductDetailResult>
    func removeProductMedia(productID: String, mediaID: String) -> Observable<DefaultResponse>
}

class ProductInteractorRx: ProductUseCase {
    
	private let repository: ProductRepository
	
	required init(repository: ProductRepository) {
		self.repository = repository
	}
    
    func deleteProduct(by id: String) -> Observable<DeleteResponse> {
        return repository.deleteProductNetwork(id: id)
    }
	
	func searchProducts(id: String, text: String) -> Observable<ProductResult> {
		return repository.searchMyProducts(id: id, text: text)
	}
	
	func getProducts(by id: String, page: Int) -> Observable<ProductResult> {
		return repository.getProductsById(by: id, page: page)
	}
    
    func getNetworkArchiveProducts(page: Int) -> Observable<ProductResult> {
        return repository.getNetworkArchiveProducts(page: page)
    }
	
    func searchArchiveProducts(text: String) -> Observable<ProductResult> {
        return repository.searchArchiveProducts(by: text)
    }
    
    func activeSearchProducts(_ active: Bool, id: String) -> Observable<ProductDetailResult> {
        return repository.activeSearchProducts(active, id: id)
    }
    
	func getNetworkProducts(page: Int) -> Observable<ProductResult> {
		return repository.getProductsNetwork(page: page)
	}
	
	func searchProducts(text: String) -> Observable<ProductResult> {
		return repository.searchProducts(by: text)
	}
	
	func getMyProducts(page: Int) -> Observable<ProductResult> {
		return repository.getMyProducts(page: page)
	}
	
    func detailProduct(id: String) -> Observable<ProductDetailResult> {
        return repository.getProductDetail(id)
    }

    func editProduct(_ product: Product) -> Observable<ProductDetailResult> {
        return repository.editProduct(product)
    }
    
    func deleteMedia(by idProduct: String, id: String) -> Observable<DeleteResponse> {
        return repository.deleteMedia(by: idProduct, id: id)
    }
    
    func addProduct(product: Product) -> Observable<ProductDetailResult> {
        print("Json productnya 3 \(product)")
        return repository.addProduct(product: product)
    }
    
    func removeProductMedia(productID: String, mediaID: String) -> Observable<DefaultResponse> {
        return repository.removeProductMedia(productID: productID, mediaID: mediaID)
    }
}
