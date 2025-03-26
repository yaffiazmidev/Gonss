//
//  HistoryOfBalanceController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ContextMenu

final class HistoryOfBalanceController: UIViewController {
	
	private let mainView: HistoryOfBalanceView
	private var router: HistoryOfBalanceRouting!
	private var presenter: HistoryOfBalancePresenter!
	private let disposeBag = DisposeBag()
	
	init(mainView: HistoryOfBalanceView) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = HistoryOfBalanceRouter(self)
		presenter = HistoryOfBalancePresenter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		bindViewModel()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		navigationController?.hideKeyboardWhenTappedAround()
		tabBarController?.tabBar.isHidden = true
		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.navigationBar.backgroundColor = .white
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.searchBar.delegate = self
	}
	
	func bindViewModel() {
		presenter.getNetworkHistoryOfBalance()
		
		self.mainView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
		
        presenter.balanceDatasource.skip(1).asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: HistoryOfBalanceItemCell.self.reuseIdentifier, cellType: HistoryOfBalanceItemCell.self)) { index, item, cell in
            let item = self.presenter.balanceDatasource.value[index]
            cell.configure(date: item.createAt ?? 0, balance: item.nominal?.toMoney() ?? "".toMoney() )
        }.disposed(by: disposeBag)
		presenter.balanceDatasource.asObservable().bind { product in
			self.mainView.tableView.reloadData()
		}.disposed(by: disposeBag)
		
		presenter.loadingState.asObservable().subscribe { bool in
			if (!bool) {
				self.mainView.refreshController.endRefreshing()
			}
		} onError: { error in
			print(error)
		} onCompleted: {
		}.disposed(by: disposeBag)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}

}


// MARK: - HistoryOfBalanceViewDelegate
extension HistoryOfBalanceController: HistoryOfBalanceViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.balanceDatasource.value.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { UITableViewCell() }
	
	func refreshUI() {
		presenter.lastPage = 0
		presenter.requestedPage = 0
		presenter.getNetworkHistoryOfBalance()
	}
	
	func filter() {
		let destination = BalanceFilterMenuController()
		self.router.filter(source: self, destination: destination)
	}
	
	func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) { }
	
	func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) { }
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		presenter.lastPage = 0
		presenter.requestedPage = 0
		let searchingText = textField.text ?? ""
		let userId = getIdUser()
		if searchingText.count > 3 {
//			presenter.searchProducts(id: userId, searchingText: searchingText)
			return true
		}
		return false
	}
	
}


// MARK: - Private Zone
private extension HistoryOfBalanceController {

}
