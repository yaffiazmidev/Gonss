//
//  AreasInteractor.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class AreasInteractor {
	
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	private let disposeBag = DisposeBag()
	let addressUseCase = Injection.init().provideAddressUseCase()
	let type: AreasTypeEnum!
	let id : String?
	
	init(type: AreasTypeEnum!, id: String?) {
		self.type = type
		self.id = id
	}
	
	func provinsiResponse() -> Observable<AreaResult> {
		return addressUseCase.fetchProvince().subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func kotaResponse() -> Observable<AreaResult> {
		return addressUseCase.fetchCity(id: id ?? "").subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func kecamatanResponse() -> Observable<AreaResult> {
		return addressUseCase.fetchSubdistrict(id: id ?? "").subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
	
	func postalCodeResponse() -> Observable<NewPostalCodeResult> {
		return addressUseCase.fetchPostalCode(id: id ?? "").subscribeOn(concurrentBackground).observeOn(MainScheduler.init())
	}
}

enum AreasTypeEnum : String {
	case province = "province"
	case city = "city"
	case subdistrict = "subdistrict"
	case postalCode = "postalCode"
}
