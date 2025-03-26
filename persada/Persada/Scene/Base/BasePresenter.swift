//
//  BasePresenter.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 19/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import RxSwift
import RxCocoa

protocol BasePresentationLogic {

}

open class BasePresenter: BasePresentationLogic {

	internal var _errorMessage = BehaviorRelay<String?>(value: nil)
	internal var errorMessage: Driver<String?> {
		return _errorMessage.asDriver()
	}
}
