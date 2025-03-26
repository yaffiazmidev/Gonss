//
//  TermAndConditionViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit

protocol TermAndConditionDisplayLogic where Self: UIViewController {

	func displayViewModel(_ viewModel: TermAndConditionModel.ViewModel)
}

class TermAndConditionViewController: UIViewController, Displayable, TermAndConditionDisplayLogic {

	private let mainView: TermAndConditionView
	private var interactor: TermAndConditionInteractable!
	private var router: TermAndConditionRouting!

	required init(mainView: TermAndConditionView, dataSource: TermAndConditionModel.DataSource) {
		self.mainView = mainView

		super.init(nibName: nil, bundle: nil)
		interactor = TermAndConditionInteractor(viewController: self, dataSource: dataSource)
		router = TermAndConditionRouter(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		//interactor.doSomething(item: 22)
	}

	override func loadView() {
		view = mainView
		view.backgroundColor = .white
		setupNav()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}


	// MARK: - TermAndConditionDisplayLogic
	func displayViewModel(_ viewModel: TermAndConditionModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {

				case .doSomething(let viewModel):
					self.displayDoSomething(viewModel)
			}
		}
	}
}


// MARK: - TermAndConditionViewDelegate
extension TermAndConditionViewController: TermAndConditionViewDelegate {

	func sendDataBackToParent(_ data: Data) {
		//usually this delegate takes care of users actions and requests through UI

		//do something with the data or message send back from mainView
	}
}


// MARK: - Private Zone
private extension TermAndConditionViewController {

	func displayDoSomething(_ viewModel: NSObject) {
		print("Use the mainView to present the viewModel")
		//example of using router
		router.routeTo(.xScene(xData: 22))
	}

	func setupNav(){
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconClose")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(self.back))
		self.title = "Syarat Dan Ketentuan"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 14)]
	}

	@objc func back(){
		router.routeTo(.dismissTermAndConditionScene)
	}

}
