//
//  ChooseProductCellViewModel.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine

final class ChooseProductCellViewModel {
	@Published var nameProduct: String = ""
	@Published var id: String = ""
	@Published var price: String = ""
	
	private let product: Product
	
	init(product: Product) {
		self.product = product

		setUpBindings()
	}
	
	private func setUpBindings() {
		nameProduct = self.product.name ?? ""
		price = String(self.product.price ?? 0)
		id = self.product.id ?? ""
	}
}

