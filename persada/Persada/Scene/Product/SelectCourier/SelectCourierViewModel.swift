//
//  SelectCourierViewModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 18/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SelectCourierViewModel {
	private let usecase = Injection.init().provideSelectCourier()
	private let disposeBag = DisposeBag()
	let courierRelay = BehaviorRelay<[CourierResult]>(value: [])
	let loadingRelay = BehaviorRelay<Bool>(value: false)
	let errorRelay = BehaviorRelay<String>(value: "")
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	
	init() {
		getCourier()
	}
	
	func getCourier(){
		loadingRelay.accept(true)
		usecase.getCourier()
			.subscribeOn(concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { (result) in
				if let data = result.data {
					self.courierRelay.accept(data)
				}
				self.loadingRelay.accept(false)
			} onError: { (error) in
				
				self.loadingRelay.accept(false)
			}.disposed(by: disposeBag)
	}
	
	func updateCourier(id: String, isActive: Bool, index: Int){
		loadingRelay.accept(true)
		usecase.updateCourier(id: id, isActive: isActive)
			.subscribeOn(concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe { (result) in
				let list = self.courierRelay.value
				var currentItem = list.filter { (result) -> Bool in
					result.id == id
				}.first
				currentItem?.status = isActive
				var filtered = list.filter { (result) -> Bool in
					result.id != id
				}
				filtered.insert(currentItem!, at: index)
				self.courierRelay.accept(filtered)
				
				self.loadingRelay.accept(false)
			} onError: { (error) in
				self.loadingRelay.accept(false)
			}.disposed(by: disposeBag)

	}
	
}
