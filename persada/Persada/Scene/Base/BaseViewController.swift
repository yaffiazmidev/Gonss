//
//  BaseViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 19/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


open class BaseViewController: UIViewController {

	private var presenter: BasePresenter!
	internal var disposeBag: DisposeBag = DisposeBag()

	func setupPresenter(presenter: BasePresenter) {
		self.presenter = presenter
	}

	open override func viewDidLoad() {
		presenter.errorMessage.drive { err in
			if let er = err {
				self.showToast(message: er)
			}
		} onCompleted: {

		}.disposed(by: disposeBag)

	}
}
