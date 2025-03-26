//
//  SelectCourierRepository.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 30/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

protocol SelectCourierRepository {
    func getActiveCourier() -> Observable<SelectCourierResult>
		func updateCourier(id: String, isActive: Bool) -> Observable<UpdateCourierResult>
}

final class SelectCourierRepositoryImpl: SelectCourierRepository {
	

	
    
    typealias SelectCourierInstance = (RxSelectCourierNetworkModel) -> SelectCourierRepository
    
    fileprivate let remote: RxSelectCourierNetworkModel
    
    private init(remote: RxSelectCourierNetworkModel) {
        self.remote = remote
    }
    
    static let sharedInstance: SelectCourierInstance = { remote in
        return SelectCourierRepositoryImpl(remote: remote)
    }
 
    
    func getActiveCourier() -> Observable<SelectCourierResult> {
        return remote.fetchActiveCourier()
    }
	
	func updateCourier(id: String, isActive: Bool) -> Observable<UpdateCourierResult> {
		return remote.updateCourier(id: id, isActive: isActive)
	}
}
