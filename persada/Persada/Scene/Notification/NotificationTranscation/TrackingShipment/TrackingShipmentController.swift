//
//  TrackingShipmentController.swift
//  KipasKipas
//
//  Created by movan on 18/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit

protocol TrackingShipmentDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: TrackingShipmentModel.ViewModel)
}

final class TrackingShipmentController: UIViewController, Displayable, TrackingShipmentDisplayLogic {
	
	private let mainView: TrackingShipmentView
	private var interactor: TrackingShipmentInteractable!
	private var router: TrackingShipmentRouting!
	
	init(mainView: TrackingShipmentView, dataSource: TrackingShipmentModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = TrackingShipmentInteractor(viewController: self, dataSource: dataSource)
		router = TrackingShipmentRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		handleRefreshNotifications()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(.get(.tracking))
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
		mainView.tableView.delegate = self
		mainView.tableView.dataSource = self
		mainView.refreshControl.addTarget(self, action: #selector(handleRefreshNotifications), for: .valueChanged)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	@objc func handleRefreshNotifications() {
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.fetchTracking(id: id))
	}
	
	
	// MARK: - TrackingShipmentDisplayLogic
	func displayViewModel(_ viewModel: TrackingShipmentModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
				
			case .trackingShipment(let viewModel):
				self.displayTrackingShipment(viewModel)
			}
		}
	}
}


// MARK: - TrackingShipmentViewDelegate
extension TrackingShipmentController: TrackingShipmentViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		self.interactor.dataSource.data?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
//		let cell = tableView.dequeueReusableCustomCell(with: TrackingItemCell.self, indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: String.get(.cellID), for: indexPath) as! TrackingItemCell
		
		guard let item = self.interactor.dataSource.data?[indexPath.item] else {
			let cell = UITableViewCell()
			cell.backgroundColor = .white
			return cell
		}
        
        if self.interactor.dataSource.data?.first?.notes == item.notes  {
            let date = item.shipmentDate ?? 0
            let desc = item.notes ?? ""
//            print("NOTES = \(self.interactor.dataSource.data?.first?.notes)")
//            print("NOTES item = \(item.notes)")
            cell.configure(date, desc, .secondary, false, true)
            return cell
        }
        
        if self.interactor.dataSource.data?.last?.notes == item.notes {
            let date = item.shipmentDate ?? 0
            let desc = item.notes ?? ""

            cell.configure(date, desc, .gainsboro, true, false)
            return cell
        }
		
		let date = item.shipmentDate ?? 0
		let desc = item.notes ?? ""
		
        cell.configure(date, desc, .gainsboro, false, false)
		
		return cell
	}


}


// MARK: - Private Zone
private extension TrackingShipmentController {
	
	func displayTrackingShipment(_ viewModel: [HistoryTracking]) {
		self.interactor.dataSource.data?.removeAll()
		self.interactor.dataSource.data = viewModel
		self.mainView.tableView.refreshControl?.endRefreshing()
		self.mainView.tableView.reloadData()
	}
}
