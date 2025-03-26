//
//  CancelSalesOrderController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 03/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol CancelSalesOrderDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: CancelSalesOrderModel.ViewModel)
}

final class CancelSalesOrderController: UIViewController, Displayable, CancelSalesOrderDisplayLogic {
	
	private let mainView: CancelSalesOrderView
	private var interactor: CancelSalesOrderInteractable!
	private var router: CancelSalesOrderRouting!
	
	init(mainView: CancelSalesOrderView, dataSource: CancelSalesOrderModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = CancelSalesOrderInteractor(viewController: self, dataSource: dataSource)
		router = CancelSalesOrderRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		interactor.doRequest(.reasonDecline)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(String.get(.detailTransaction))
		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationItem.title = String.get(.cancelOrder)
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - CancelSalesOrderDisplayLogic
	func displayViewModel(_ viewModel: CancelSalesOrderModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .cancelOrder(let viewModel):
				self.displayCancelOrder(viewModel)
			case .reasons(let viewModel):
				self.displayReasons(viewModel)
			}
		}
	}
}


// MARK: - CancelSalesOrderViewDelegate
extension CancelSalesOrderController: CancelSalesOrderViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
	
	func dismiss() {
		mainView.sendSubviewToBack(mainView.viewDialogPopup)
		mainView.viewPopupBackground.isHidden = true
		mainView.viewDialogPopup.isHidden = true
		mainView.viewPopupBackground.alpha = 0.0
		mainView.viewDialogPopup.alpha = 0.0
		mainView.tableView.alpha = 1
	}
	
	func showDialog() {
		mainView.bringSubviewToFront(mainView.viewDialogPopup)
		mainView.viewPopupBackground.isHidden = false
		mainView.viewDialogPopup.isHidden = false
		mainView.viewPopupBackground.alpha = 0.75
		mainView.viewDialogPopup.alpha = 1.0
		mainView.tableView.alpha = 0
	}
	
	func dismissBacktoRoot() {
		router.routeTo(.dismiss)
	}
	
	func confirmFinalCancel() {
		guard let reason = self.interactor.dataSource.data else { return }
		self.interactor.doRequest(.cancelSalesOrder(reason: reason))
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.interactor.dataSource.dataReasons?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		
		let cell = tableView.dequeueReusableCustomCell(with: ReportFeedCell.self, indexPath: indexPath)
		
		cell.selectionStyle = .none
		guard let reasons = self.interactor.dataSource.dataReasons else { return cell }
		
		cell.item = reasons[row].value == "" ? .get(.otherReason) : reasons[row].value
		cell.layer.cornerRadius = 8
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let item = interactor.dataSource.dataReasons?.count
		switch indexPath.row {
		case item:
			return 140
		default:
			return 60
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		let id = interactor.dataSource.id
		
		guard let item = interactor.dataSource.dataReasons?[row] else {
			return
		}
		
		switch row {
		case 0, 1, 2, 3:
			
			let validData = CancelSalesOrderInput(type: item.type, targetReportedId: id, reasonReport: item)
			self.interactor.dataSource.data = validData
			mainView.reasonCTV.isHidden = true
			
		case 4:
			
			let valueText = self.mainView.reasonCTV.nameTextField.text ?? ""
			let validItem: DeclineOrder = DeclineOrder(id: item.id, type: item.type, value: valueText)
			let validData = CancelSalesOrderInput(type: "decline_order", targetReportedId: id, reasonReport: validItem)
			self.interactor.dataSource.data = validData
			
			mainView.reasonCTV.isHidden = false
		default:
			break
		}
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: mainView.tableView.frame.width, height: 500))
		headerView.backgroundColor = .white
		let titleLabel = UILabel(text: .get(.titleCancelSalesItem), font: .Roboto(.bold, size: 16), textColor: .black, textAlignment: .center, numberOfLines: 0)
		titleLabel.backgroundColor = .white
		headerView.addSubview(titleLabel)
		titleLabel.centerYTo(headerView.centerYAnchor)

		return headerView
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
}


// MARK: - Private Zone
private extension CancelSalesOrderController {

	func displayCancelOrder(_ viewModel: DefaultResponse) {
		self.showDialog()
	}
	
	func displayReasons(_ viewModel: [DeclineOrder]) {
		interactor.dataSource.dataReasons = viewModel
		mainView.tableView.reloadData()
	}

}
