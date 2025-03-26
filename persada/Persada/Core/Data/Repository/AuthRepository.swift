//
//  AuthRepository.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 04/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

protocol AuthRepository {
	func logoutAndClearCache() -> Observable<DefaultResponse>
}

final class AuthRepositoryImpl: AuthRepository {


	typealias AuthInstance = (RxAuthNetworkModel) -> AuthRepository

	fileprivate let remote: RxAuthNetworkModel

	private init(remote: RxAuthNetworkModel) {
		self.remote = remote
	}

	static let sharedInstance: AuthInstance = { remoteRepo in
		return AuthRepositoryImpl(remote: remoteRepo)
	}

	func logoutAndClearCache() -> Observable<DefaultResponse> {
		return self.remote.logout()
	}

}
