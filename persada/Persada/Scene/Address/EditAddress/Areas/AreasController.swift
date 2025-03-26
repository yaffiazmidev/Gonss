//
//  AreasController.swift
//  KipasKipas
//
//  Created by movan on 12/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


final class AreasController: UIViewController, AlertDisplayer {
	
	private let mainView: AreasView
	private var presenter: AreasPresenter!
	private let disposeBag = DisposeBag()
	private var type : AreasTypeEnum!
	
	init(mainView: AreasView, type: AreasTypeEnum, id: String?) {
		self.mainView = mainView
		self.type = type
		
		super.init(nibName: nil, bundle: nil)
		
		
		let interactor = AreasInteractor(type: type, id: id)
		let router = AreasRouter(self)
		presenter = AreasPresenter(router: router, interactor: interactor)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setTableView()
		setSearch()
		createErrorObserver()
		
		mainView.tableView.refreshControl = mainView.refreshControl
		mainView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
	}
	
	@objc func handleRefresh() {
		self.presenter.fetchResult()
		self.mainView.refreshControl.endRefreshing()
	}
	
	func createErrorObserver(){
		presenter.errorRelay.bind { (error) in
			if let error = error?.localizedDescription {
				let action = UIAlertAction(title: StringEnum.ok.rawValue, style: .default)
				self.displayAlert(with: StringEnum.error.rawValue, message: error, actions: [action])
			}
		}.disposed(by: disposeBag)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(.get(.provinsi))
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}

	override func loadView() {
		view = mainView
		mainView.backgroundColor = .white
	}
	
	func setTableView(){
        switch self.type {
        case .postalCode:
            
            presenter.filteredresultPostalCode.asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: AreasView.ViewTrait.cellId, cellType: AreasItemCell.self)) { index, model, cell in
                print("value item: ")
                cell.item = model.value
            }.disposed(by: disposeBag)
            print("postalcode middle")
            mainView.tableView.rx.itemSelected.observeOn(MainScheduler.instance)
                .subscribe {[weak self] (path) in
                    self?.presenter.didSelectRowTrigger.onNext(path)
                }.disposed(by: disposeBag)
            print("postalcode end")
        default:
            presenter.filteredresult.asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: AreasView.ViewTrait.cellId, cellType: AreasItemCell.self)) { index, model, cell in
                cell.item = model.name
            }.disposed(by: disposeBag)
            
            mainView.tableView.rx.itemSelected.observeOn(MainScheduler.instance)
                .subscribe {[weak self] (path) in
                    self?.presenter.didSelectRowTrigger.onNext(path)
                }.disposed(by: disposeBag)
        }
	}
	
	func setSearch(){
		mainView.searchBar.rx.text
				.orEmpty
				.distinctUntilChanged()
				.bind(to: presenter.searchValue)
				.disposed(by: disposeBag)
	}

}

