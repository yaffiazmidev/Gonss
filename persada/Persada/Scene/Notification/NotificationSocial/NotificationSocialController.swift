//
//  NotificationSocialController.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationSocialController: UIViewController {
    
	let mainView: NotificationSocialView
	private var router: NotificationSocialRouter!
		var presenter : NotificationSocialPresenter!
    private let disposeBag = DisposeBag()
	
	init(mainView: NotificationSocialView) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = NotificationSocialRouter(self)
        presenter = NotificationSocialPresenter(router: router)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
        setTableView()
	}
	
    func setTableView(){
        presenter.notificationResult.asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: NotificationSocialView.ViewTrait.cellId, cellType: NotificationSocialItemCell.self)) { index, model, cell in
            
            cell.setUpCell(item: model)
        }.disposed(by: disposeBag)
        
        mainView.tableView.rx.itemSelected
            .subscribe { [weak self](path) in
            
                self?.presenter.selectRow(indexPath: path)
                
            }.disposed(by: disposeBag)
        
        self.mainView.tableView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
            let items = self.presenter.notificationResult.value
            if indexPath.row == items.count - 2 {
                self.presenter.fetchNotificationResult()
            }
        }).disposed(by: disposeBag)
        
//        self.presenter.notificationResult.map { $0.count != 0 }
//                    .bind(to: self.mainView.labelEmptyPlaceholder.rx.isHidden)
//                    .disposed(by: self.disposeBag)
        
        presenter.isEmpty.bind { [weak self] (isEmpty) in
            if let isEmpty = isEmpty {
                self?.mainView.labelEmptyPlaceholder.isHidden = !isEmpty
            }
        }.disposed(by: disposeBag)
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

        let totalNotifIsRead = self.presenter.notificationResult.value.filter { $0.isRead == false }.count
        NotificationCenter.default.post(name: .notifyUpdateCounterSocial, object: ["NotifyUpdateCounterSocial" : Tampung(page: self.presenter.page, size: totalNotifIsRead)])
        
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
        NotificationCenter.default.post(name: .notifyCounterSocial, object: nil)
	}
}
