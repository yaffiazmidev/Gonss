//
//  ReportMenuController.swift
//  Persada
//
//  Created by Muhammad Noor on 14/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class
ReportMenuController: UITableViewController, AlertDisplayer {
	
	private var rows = 0
	private var id: String = ""
	private var accountId: String = ""
	private var imageUrl: String = ""
	private let disposeBag = DisposeBag()
	private let networkReport = ReportNetworkModel()
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
		tableView.reloadData()
		tableView.separatorColor = .clear
		tableView.layoutIfNeeded()
		preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
		navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
		tableView.backgroundColor = .clear
	}
	
	func source(id: String, accountId: String, imageUrl: String, rows: Int) {
		self.rows = rows
		self.id = id
		self.imageUrl = imageUrl
		self.accountId = accountId
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Int(rows)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.font = .Roboto(.bold, size: 17)
		cell.textLabel?.textColor = .darkGray
		cell.backgroundColor = .clear
		cell.accessoryType = .disclosureIndicator
		
		if rows == 1 {
			cell.textLabel?.text = "Report"
		} else {
			if indexPath.row == 0 {
				cell.textLabel?.text = "Delete"
			} else {
				cell.textLabel?.text = "Report"
			}
		}
		
		
		return cell
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
		if rows == 1 {
			networkReport.checkIsReportExist(.reportsExist(id: id)) { result in
				switch result {
					case .success(let isExist):
						DispatchQueue.main.async {
						if !(isExist.data ?? false) {
							let reportController = ReportFeedController(viewModel: ReportFeedViewModel(id: self.id, imageUrl: self.imageUrl, accountId: self.accountId, networkModel: ReportNetworkModel()))
							self.present(reportController, animated: true, completion: nil)
						} else {
								self.displayAlert(with: "Report", message: "Anda sudah melakukan report terhadap post ini", actions: [UIAlertAction(title: "OK", style: .cancel)])
							}
						}
					case .failure(let err):
						DispatchQueue.main.async {
							self.displayAlert(with: "Error", message: err?.localizedDescription ?? "", actions: [UIAlertAction(title: "OK", style: .cancel)])
						}
				}

			}

		} else {
			if indexPath.row == 1 {
				let reportController = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, networkModel: ReportNetworkModel()))
				self.present(reportController, animated: true, completion: nil)
			} else {
				let title = "Warning"
				let action = UIAlertAction(title: "OK", style: .default) { (action) in

					let usecase = Injection.init().provideFeedUseCase()

					usecase.deleteFeedById(id: self.id)
						.subscribeOn(self.concurrentBackground)
						.observeOn(MainScheduler.instance)
						.subscribe { result in
							DispatchQueue.main.async {
								self.dismiss(animated: true, completion: nil)
							}
						} onError: { err in
							print(err)
						}.disposed(by: self.disposeBag)

//					network.deletePost(.deletePost(id: self.id)).sink(receiveCompletion: { (completion) in
//						switch completion {
//						case .failure(let error): print(error.localizedDescription)
//						case .finished: break
//						}
//					}) { (model: DeleteResponse) in
//						if model.code == "1000" {
//							DispatchQueue.main.async {
//								self.dismiss(animated: true, completion: nil)
//							}
//						}
//					}.store(in: &self.subscriptions)
				}
				let cancel = UIAlertAction(title: "Cancel", style: .cancel)
					
				self.displayAlert(with: title , message: "Yakin ingin menghapus postingan ini? ", actions: [action, cancel])
			}
		}
	}
}
