//
//  DetailOfBalanceController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 15/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

final class DetailOfBalanceController: UIViewController {
	
	private let mainView: DetailOfBalanceView
	private var router: DetailOfBalanceRouter!
	private var presenter: DetailOfBalancePresenter!
	private let disposeBag = DisposeBag()
	
	init(mainView: DetailOfBalanceView) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		presenter = DetailOfBalancePresenter(router)
		router = DetailOfBalanceRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setTableView()
	}
	
	func setTableView() {
		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
}


// MARK: - DetailOfBalanceViewDelegate
extension DetailOfBalanceController: DetailOfBalanceViewDelegate, UIGestureRecognizerDelegate {
	

}

