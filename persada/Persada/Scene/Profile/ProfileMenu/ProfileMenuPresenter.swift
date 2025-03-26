//
//  ProfileMenuPresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 10/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation
import RxSwift
import RxCocoa
import KipasKipasShared

protocol ProfileMenuPresentationLogic {
  func presentResponse(_ response: ProfileMenuModel.Response)
}

final class ProfileMenuPresenter: Presentable {
  private weak var viewController: ProfileMenuDisplayLogic?
	private let disposeBag = DisposeBag()
	private let usecase: AuthUseCase
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
  
  init(_ viewController: ProfileMenuDisplayLogic?) {
    self.viewController = viewController
		self.usecase = Injection.init().provideAuthUseCase()
  }


	private let _errorMessage = BehaviorRelay<String?>(value: nil)
	var errorMessage: Driver<String?> {
		return _errorMessage.asDriver()
	}

	let _loadingState = BehaviorRelay<Bool>(value: false)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}

	func logout() {
        self._loadingState.accept(true)
        
        // nanti buat feature modular logout
        KeychainUserStore().remove()
        KKCache.common.remove(key: .trendingCache)
		return usecase.logoutClearCache().subscribeOn(self.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe{ result in
				self._loadingState.accept(false)
				let result:ResultData<DefaultResponse> = ResultData<DefaultResponse>.success(result)

				self.viewController?.displayLogout(result: result)
			} onError: { err in
                self._loadingState.accept(false)
				let result:ResultData<DefaultResponse> = ResultData<DefaultResponse>.failure(ErrorMessage(statusCode: 500, statusMessage: err.localizedDescription, statusData: err.localizedDescription))
				self.viewController?.displayLogout(result: result)
			} onCompleted: {
			}.disposed(by: disposeBag)
	}
}


// MARK: - ProfileMenuPresentationLogic
extension ProfileMenuPresenter: ProfileMenuPresentationLogic {
  
  func presentResponse(_ response: ProfileMenuModel.Response) {
    
    switch response {
    case .doSomething(let newItem, let isItem):
      presentDoSomething(newItem, isItem)
    }
  }
}


// MARK: - Private Zone
private extension ProfileMenuPresenter {
  
  func presentDoSomething(_ newItem: Int, _ isItem: Bool) {
    
    //prepare data for display and send it further
    
   
  }
}
