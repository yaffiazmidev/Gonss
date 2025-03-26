//
//  ProvinceController.swift
//  MOVANS
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol ProvinceDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: ProvinceModel.ViewModel)
}

final class ProvinceController: UIViewController, Displayable, ProvinceDisplayLogic {
	
	private let mainView: ProvinceView
	private var interactor: ProvinceInteractable!
	private var router: ProvinceRouting!
	
	init(mainView: ProvinceView, dataSource: ProvinceModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = ProvinceInteractor(viewController: self, dataSource: dataSource)
		router = ProvinceRouter(self)
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
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - ProvinceDisplayLogic
	func displayViewModel(_ viewModel: ProvinceModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .doSomething(let viewModel):
				self.displayDoSomething(viewModel)
			}
		}
	}
}


// MARK: - ProvinceViewDelegate
extension ProvinceController: ProvinceViewDelegate, UIGestureRecognizerDelegate {
	
	func sendDataBackToParent(_ data: Data) {
		//usually this delegate takes care of users actions and requests through UI
		
		//do something with the data or message send back from mainView
	}
}


// MARK: - Private Zone
private extension ProvinceController {
	
	func displayDoSomething(_ viewModel: NSObject) {
		print("Use the mainView to present the viewModel")
		
	}
}
