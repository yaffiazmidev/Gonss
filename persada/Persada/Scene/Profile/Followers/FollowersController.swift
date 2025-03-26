//
//  FollowersController.swift
//  KipasKipas
//
//  Created by movan on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine
import RxSwift
import KipasKipasShared

protocol FollowersDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: FollowersModel.ViewModel)
}

final class FollowersController: UIViewController, Displayable, FollowersDisplayLogic {
	
	private let mainView: FollowersView
	private var interactor: FollowersInteractable!
	private var router: FollowersRouting!
	private var subscriptions = Set<AnyCancellable>()
    private let disposeBag = DisposeBag()
	
	init(mainView: FollowersView, dataSource: FollowersModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = FollowersInteractor(viewController: self, dataSource: dataSource)
		router = FollowersRouter(self)
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationController?.setNavigationBarHidden(false, animated: false)
		refresh()
		
        self.interactor.dataSource.$data
            .receive(on: DispatchQueue.main)
            .map{ !($0?.count == 0 && self.mainView.searchBar.text.isNilOrEmpty)}
            .assign(to: \.isHidden, on: mainView.labelEmptyPlaceholder)
            .store(in: &subscriptions)
        
		self.interactor.dataSource.$data
			.receive(on: DispatchQueue.main)
            .map{ !($0?.count == 0 && !self.mainView.searchBar.text.isNilOrEmpty) }
            .assign(to: \.isHidden, on: mainView.labelEmptySearchView)
			.store(in: &subscriptions)
        
        let validId = self.interactor.dataSource.id ?? ""
        mainView.searchBar.rx.controlEvent(.editingChanged)
            .withLatestFrom(mainView.searchBar.rx.text.orEmpty)
            .debounce(.milliseconds(1500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.mainView.labelEmptySearchView.searchText = text
                !text.isEmpty ? self.interactor.doRequest(.searchAccount(id: validId, text: text)) : self.refresh()
            }).disposed(by: disposeBag)
	}
	
	@objc private func back() {
		let validId = self.interactor.dataSource.id ?? ""
		let showNavBar = self.interactor.dataSource.showNavBar ?? false
		router.routeTo(.dismiss(id: validId, showNavBar: showNavBar))
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
//		bindNavigationBar(String.get(.follower))
		title = .get(.follower)
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
		mainView.searchBar.delegate = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - FollowersDisplayLogic
	func displayViewModel(_ viewModel: FollowersModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .paginationFollowers(let viewModel):
				self.displayPaginationFollowers(viewModel)
			case .followers(let viewModel):
				self.displayListFollowers(viewModel)
			case .account(let viewModel):
				self.displaySearchAccount(viewModel)
			case .follow(let viewModel):
				self.displayResponseFollow(viewModel)
			case .unfollow(let viewModel):
				self.displayResponseUnfollow(viewModel)
			}
		}
	}
}


// MARK: - FollowersViewDelegate
extension FollowersController: FollowersViewDelegate, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {}
	
	func refresh () {
        let validId = self.interactor.dataSource.id ?? ""
        let queryText = mainView.searchBar.text
        
        if !queryText.isNilOrEmpty{
            self.interactor.doRequest(.searchAccount(id: validId, text: queryText ?? ""))
            return
        }
        
		self.interactor.page = 0
		self.interactor.doRequest(.fetchFollowers(id: validId, isPagination: false))
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.interactor.dataSource.data?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCustomCell(with: FollowersItemCell.self, indexPath: indexPath)
		cell.selectionStyle = .none
		
		guard let item = self.interactor.dataSource.data, let id = item[indexPath.row].id else {
			return cell
		}
		
		cell.handlerFollow = { [weak self] in
			self?.interactor.dataSource.index = indexPath.row
			if item[indexPath.row].isFollow == true {
				self?.interactor.doRequest(.unfollow(id: id))
			} else {
				self?.interactor.doRequest(.follow(id: id))
			}
		}
		
		cell.handlerTappedImageView = { [weak self] in
			self?.router.routeTo(.detail(id: id))
		}
        
        cell.handlerRemoveFollower = { [weak self] in
            guard let self = self else { return }
            let vc = CustomPopUpViewController(
                title: "Fitur sedang dalam proses pengembangan.",
                description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
                iconImage: UIImage(named: "img_in_progress"),
                iconHeight: 99
            )
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        
		
		cell.data = item[indexPath.row]
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 66
	}

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = self.interactor.dataSource.data, let id = interactor.dataSource.id else { return }
        if indexPath.row == item.count - 2 {
            self.interactor.doRequest(.fetchFollowers(id: id, isPagination: true))
        }
    }
}


// MARK: - Private Zone
private extension FollowersController {
	
	func displayPaginationFollowers(_ viewModel: [Follower]) {
        interactor.dataSource.data?.append(contentsOf: unique(data: viewModel))
        mainView.tableView.reloadData()
	}

	func displayListFollowers(_ viewModel: [Follower]) {
		interactor.dataSource.data?.removeAll()
		interactor.dataSource.data = unique(data: viewModel)
		mainView.refreshControl.endRefreshing()
		mainView.tableView.reloadData()
	}
	
	func displaySearchAccount(_ viewModel: [Follower]) {
		interactor.dataSource.data?.removeAll()
		interactor.dataSource.data = unique(data: viewModel)
		mainView.refreshControl.endRefreshing()
		mainView.tableView.reloadData()
	}
	
	func displayResponseFollow(_ viewModel: DefaultResponse) {
        updateDataSourceFollowers(data: viewModel, isFollow: true)
	}
	
	func displayResponseUnfollow(_ viewModel: DefaultResponse) {
        updateDataSourceFollowers(data: viewModel, isFollow: false)
	}
    
    func updateDataSourceFollowers(data: DefaultResponse, isFollow: Bool) {
        guard let index = interactor.dataSource.index else {
            return
        }
        
        interactor.dataSource.data?[index].isFollow = isFollow
        let user = interactor.dataSource.data?[index]
        mainView.tableView.reloadData()
        NotificationCenter.default.post(name: .notificationUpdateProfile, object: nil, userInfo: nil)
        let data: [String : Any] = [
            "accountId" : user?.id ?? "",
            "isFollow": user?.isFollow ?? false,
            "name": user?.name ?? "",
            "photo": user?.photo ?? ""
        ]
        NotificationCenter.default.post(name: .updateIsFollowFromFolowingFolower, object: nil, userInfo: data)
    }
    
    func unique(data: [Follower]) -> [Follower] {
        var uniqueFollowers: [Follower] =  []
        
        for datum in data {
            if !uniqueFollowers.contains(datum) && !(interactor.dataSource.data?.contains(datum) ?? false) {
                uniqueFollowers.append(datum)
            }
        }
        
        return uniqueFollowers
    }
}
