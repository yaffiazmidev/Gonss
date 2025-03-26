//
//  ProductOptionsController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 01/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import ContextMenu
import RxSwift

class ProductOptionsController: UITableViewController, AlertDisplayer {
	
	private var texts: [String] = []
	private let disposeBag = DisposeBag()
	private let networkReport = ReportNetworkModel()
	let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.reloadData()
		tableView.separatorColor = .clear
		tableView.layoutIfNeeded()
		preferredContentSize = CGSize(width: 220, height: tableView.contentSize.height)
		navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
		tableView.backgroundColor = .clear
	}
	
	func source(texts: [String]) {
		self.texts = texts
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return texts.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell()
		let row = indexPath.row
		cell.textLabel?.numberOfLines = 2
		cell.textLabel?.font = .Roboto(.regular, size: 13)
		cell.textLabel?.textColor = row == 4 ? .systemRed : .darkGray
		cell.backgroundColor = .clear
		cell.accessoryType = .disclosureIndicator
		cell.textLabel?.text = texts[row]
		return cell
	}
}
