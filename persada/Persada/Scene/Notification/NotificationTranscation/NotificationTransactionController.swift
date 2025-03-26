//
//  NotificationTransactionController.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class NotificationTransactionController: UIViewController {
	
	let mainView: NotificationTransactionView
	private var router: NotificationTransactionRouter!
	var presenter : NotificationTransactionPresenter!
	private let disposeBag = DisposeBag()
	
	init(mainView: NotificationTransactionView) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = NotificationTransactionRouter(self)
		presenter = NotificationTransactionPresenter(router: router)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setTableView()
	}
	
	func setTableView(){
        mainView.tableView.tableHeaderView = getHeaderView()
        mainView.tableView.tableHeaderView?.layoutIfNeeded()
        mainView.tableView.tableHeaderView = self.mainView.tableView.tableHeaderView
        
		presenter.notificationResult.asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: NotificationTransactionView.ViewTrait.cellId, cellType: NotificationTransactionItemCell.self)) { index, model, cell in
			
			cell.setUpCell(item: model)
			
		}.disposed(by: disposeBag)
		
		mainView.tableView.rx.itemSelected.observeOn(MainScheduler.instance)
			.subscribe { [weak self](path) in
				self?.presenter.selectRow(indexPath: path)
			}.disposed(by: disposeBag)
		
        self.mainView.tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            let items = self.presenter.notificationResult.value
            if indexPath.row == items.count - 2 {
                self.presenter.fetchNotificationResult()
            }
        }).disposed(by: disposeBag)
	
        presenter.notificationResult.map { $0.count != 0 }
                    .bind(to: mainView.labelEmptyPlaceholder.rx.isHidden)
                    .disposed(by: disposeBag)
        
        presenter.notificationResult
            .observeOn(MainScheduler.instance)
            .bind(onNext: { [weak self] result in
                guard let self = self else { return }
                self.mainView.tableView.tableHeaderView = result.count <= 0 ?  UIView() : self.getHeaderView()
            }).disposed(by: disposeBag)
		
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        let totalNotifIsRead = self.presenter.notificationResult.value.filter { $0.isRead == false }.count
        NotificationCenter.default.post(name: .notifyUpdateCounterTransaction, object: ["NotifyUpdateCounterTransaction" : Tampung(page: self.presenter.page, size: totalNotifIsRead)])
        
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.tableView.refreshControl = mainView.refreshControl
		mainView.refreshControl.addTarget(self, action: #selector(handleRefreshNotifications), for: .valueChanged)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	@objc func handleRefreshNotifications() {
		self.mainView.refreshControl.endRefreshing()
        presenter.page = 0
        presenter.fetchNotificationResult()
        NotificationCenter.default.post(name: .notifyCounterTransaction, object: nil)
	}
	
	private func getHeaderView() -> UIView {
        
		let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
		let iconImage = UIImageView(image: UIImage(named: String.get(.iconStatusTransactionFill)))
        iconImage.backgroundColor = .white
		let navImage = UIImageView(image: UIImage(named: String.get(.iconNavigateNext))?.withRenderingMode(.alwaysTemplate))
		navImage.tintColor = .secondary
        navImage.backgroundColor = .white
		
		let textLabel = UILabel(text: StringEnum.statusTransaction.rawValue, font: .Roboto(.medium, size: 14), textColor: .secondary, textAlignment: .center, numberOfLines: 0)
		textLabel.backgroundColor = .white
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.layer.masksToBounds = false
		button.layer.borderWidth = 1
		button.layer.cornerRadius = 8
		button.layer.borderColor = UIColor.secondaryLowTint.cgColor
		button.addTarget(self, action: #selector(handleDetailTransaction), for: .touchUpInside)
		
		[iconImage, navImage, textLabel].forEach {
			headerView.addSubview($0)
		}
        
        headerView.addSubview(button)
        button.fillSuperview(padding: UIEdgeInsets(top: 20, left: 0, bottom: 12, right: 0))
        iconImage.contentMode = .scaleToFill
        iconImage.anchor(left: headerView.leftAnchor, paddingLeft: 16, width: 16, height: 16)
        iconImage.centerYTo(button.centerYAnchor)
        navImage.anchor(right: headerView.rightAnchor, paddingRight: 16, width: 16, height: 16)
        navImage.centerYTo(button.centerYAnchor)
        textLabel.anchor(top: headerView.topAnchor, left: iconImage.rightAnchor, paddingLeft: 8, paddingRight: 30)
        textLabel.centerYTo(button.centerYAnchor)
        
		return headerView
	}
	
	@objc func handleDetailTransaction() {
		self.presenter.routeToStatusTransaction()
	}
	
}
