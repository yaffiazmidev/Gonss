//
//  RxSelectCourierNetworkModel.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 29/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxSelectCourierNetworkModel {
    private let network: Network<SelectCourierResult>
		private let networkDefault: Network<UpdateCourierResult>
    
	init(network: Network<SelectCourierResult>, networkDefault: Network<UpdateCourierResult>) {
        self.network = network
			self.networkDefault = networkDefault
    }
    
    func fetchActiveCourier() -> Observable<SelectCourierResult> {
			let endpoint = CourierEndpoint.getCourier
			return network.getItems(endpoint.path, parameters: [:])
    }
	
	func updateCourier(id: String, isActive: Bool) -> Observable<UpdateCourierResult> {
		let endpoint = CourierEndpoint.editCourier(id: id, isActive: isActive)
		return networkDefault.putItem(endpoint.path, parameters: endpoint.parameter)
	}
}
