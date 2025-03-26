//
//  DetailSearchTopController.swift
//  KipasKipas
//
//  Created by movan on 04/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol DetailSearchTopDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: DetailSearchTopModel.ViewModel)
}

final class DetailSearchTopController: UIViewController, Displayable, DetailSearchTopDisplayLogic {
	
	private let mainView: DetailSearchTopView
	private var interactor: DetailSearchTopInteractable!
	private var router: DetailSearchTopRouting!
	
	init(mainView: DetailSearchTopView, dataSource: DetailSearchTopModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = DetailSearchTopInteractor(viewController: self, dataSource: dataSource)
		router = DetailSearchTopRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//interactor.doSomething(item: 22)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
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
		mainView.delegate = self
		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - DetailSearchTopDisplayLogic
	func displayViewModel(_ viewModel: DetailSearchTopModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .channels(let viewModel):
				self.displayDoTopChannel(viewModel)
			case .paginationChannel(let viewModel):
				self.displayDoPaginationChannel(viewModel)
			}
		}
	}
}


// MARK: - DetailSearchTopViewDelegate
extension DetailSearchTopController: DetailSearchTopViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let items = self.interactor.dataSource.data else {
			return 0
		}
		
		return items.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailSearchTopView.cellId, for: indexPath) as! DetailSearchTopItemCell
		
		guard let items = self.interactor.dataSource.data else {
			return cell
		}
		
		cell.item = items[indexPath.row]
		
		if indexPath.row == items.count - 1 {
			let page = interactor.page
			if ( (items.count/6) >= page ) {
				self.interactor?.setPage(page + 1)
				self.interactor?.doRequest(.searchDetailTop(isPagination: true))
			}
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = UIScreen.main.bounds.width
		return CGSize(width: width, height: 400)
	}
}


// MARK: - Private Zone
private extension DetailSearchTopController {
	
	func displayDoTopChannel(_ viewModel: [Feed]) {
		self.interactor.dataSource.data = viewModel
		mainView.collectionView.reloadData()
	}
	
	func displayDoPaginationChannel(_ viewModel: [Feed]) {
		DispatchQueue.global(qos: .background).async {
			self.interactor.dataSource.data?.append(contentsOf: viewModel)
		}
		
		mainView.collectionView.reloadData()
	}
}
