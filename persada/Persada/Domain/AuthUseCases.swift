//
//  AuthUseCases.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 04/01/21.
//  Copyright © 2021 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift

protocol AuthUseCase {
	func logoutClearCache() -> Observable<DefaultResponse>
}

class AuthInteractorRx: AuthUseCase {

	private let repository: AuthRepository

	required init(repository: AuthRepository) {
		self.repository = repository
	}

	func logoutClearCache() -> Observable<DefaultResponse> {
		return repository.logoutAndClearCache()
	}
}
