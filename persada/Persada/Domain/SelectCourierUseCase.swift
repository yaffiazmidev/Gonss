//
//  SelectCourierUseCase.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 29/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol SelectCourierUseCase: AnyObject {
    func getCourier() -> Observable<SelectCourierResult>
	func updateCourier(id: String, isActive: Bool) -> Observable<UpdateCourierResult>
}

class SelectCourierRx: SelectCourierUseCase {
    private let repository: SelectCourierRepository
    
    required init(repository: SelectCourierRepository) {
        self.repository = repository
    }
    
    func getCourier() -> Observable<SelectCourierResult> {
        return repository.getActiveCourier()
    }
	
	func updateCourier(id: String, isActive: Bool) -> Observable<UpdateCourierResult> {
		return repository.updateCourier(id: id, isActive: isActive)
	}
    
}
