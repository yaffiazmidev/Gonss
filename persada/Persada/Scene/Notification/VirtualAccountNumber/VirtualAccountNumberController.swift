//
//  VirtualAccountNumberController.swift
//  KipasKipas
//
//  Created by movan on 19/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol VirtualAccountNumberDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: VirtualAccountNumberModel.ViewModel)
}

final class VirtualAccountNumberController: UIViewController, Displayable, VirtualAccountNumberDisplayLogic {
	
	private let mainView: VirtualAccountNumberView
	private var interactor: VirtualAccountNumberInteractable!
	private var router: VirtualAccountNumberRouting!
	
	init(mainView: VirtualAccountNumberView, dataSource: VirtualAccountNumberModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = VirtualAccountNumberInteractor(viewController: self, dataSource: dataSource)
		router = VirtualAccountNumberRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        mainView.virtualAccountView.handler = {
            UIPasteboard.general.string = self.mainView.virtualAccountView.numberLabel.text
            self.showToast(message: "Copied to clipboard", font: .Roboto(.regular))
        }
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar()
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
		mainView.setData(accountNumber: interactor.dataSource.bankNumber ?? "", bankName: interactor.dataSource.bankName ?? "", time: interactor.dataSource.time ?? 0)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - VirtualAccountNumberDisplayLogic
	func displayViewModel(_ viewModel: VirtualAccountNumberModel.ViewModel) {
		DispatchQueue.main.async {
//			switch viewModel {
//			}
		}
	}
}


// MARK: - VirtualAccountNumberViewDelegate
extension VirtualAccountNumberController: VirtualAccountNumberViewDelegate, UIGestureRecognizerDelegate {
	
	func dismiss() {
		self.router.routeTo(.dismissVirtualAccountNumberScene)
	}
}


// MARK: - Private Zone
private extension VirtualAccountNumberController {
	
//	func display<#T##title: String?##String?#>(_ viewModel: <#T##title: String?##String?#>) {
//		
//	}
}
