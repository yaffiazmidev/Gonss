//
//  ViewModelProductActionSheet.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModelProductActionSheet {
	
	let productUsecase = Injection.init().provideProductUseCase()
	private let disposeBag = DisposeBag()
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	func archiveProduct(productID : String, archive: Bool, onSuccessArchive: @escaping ()->(), onArchiveError: @escaping (String)->()){
			productUsecase.activeSearchProducts(archive, id: productID)
					.subscribe(onNext: { (result) in
							onSuccessArchive()
					}, onError: { (error) in
						onArchiveError(error.localizedDescription)
					}).disposed(by: disposeBag)
	}
	
	func deleteProduct(productID : String, onSuccessDelete: @escaping ()->(), onDeleteError: @escaping (String)->()){
			productUsecase.deleteProduct(by: productID)
					.subscribe(onNext: { (result) in
							onSuccessDelete()
					}, onError: { (error) in
						onDeleteError(error.localizedDescription)
					}).disposed(by: disposeBag)
	}
}
