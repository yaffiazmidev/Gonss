//
//  RxAuthNetworkModel.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 04/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift


public final class RxAuthNetworkModel {
	private let networkDefault: Network<DefaultResponse>

	init(networkDefault: Network<DefaultResponse>) {
		self.networkDefault = networkDefault
	}

	func logout() -> Observable<DefaultResponse> {
		let request = AuthEndpoint.logout(token: getToken() ?? "")
		return networkDefault.postItem(request.path, parameters: request.parameter, headers: [:])
	}

}
