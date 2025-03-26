//
//  ChooseProductController.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine

final class ChooseProductController: UIViewController {
	private lazy var contentView = ChooseProductView()
	private let viewModel: ChooseProductViewModel
	private var subscriptions = Set<AnyCancellable>()
	
	var handlerSelectedProduct: ((_ id: String) -> Void)?
	
	init(viewModel: ChooseProductViewModel = ChooseProductViewModel()) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = contentView
	}
	
	override func viewDidLoad() {
		view.backgroundColor = .darkGray
		hideKeyboardWhenTappedAround()
		setUpTableView()
		setUpsubscriptions()
	}
	
	private func setUpTableView() {
		contentView.tableView.register(ChooseProductCellItem.self, forCellReuseIdentifier: ChooseProductCellItem.identifier)
		contentView.tableView.dataSource = self
		contentView.tableView.delegate = self
	}
	
	private func setUpsubscriptions() {
		func bindViewToViewModel() {
			contentView.searchTextField.textPublisher
				.debounce(for: 0.5, scheduler: RunLoop.main)
				.removeDuplicates()
				.assign(to: \.searchText, on: viewModel)
				.store(in: &subscriptions)
		}
		
		func bindViewModelToView() {
			let viewModelsValueHandler: ([ChooseProductCellViewModel]) -> Void = { [weak self] _ in
				self?.contentView.tableView.reloadData()
			}
			
			viewModel.$chooseProductViewModels
				.receive(on: RunLoop.main)
				.sink(receiveValue: viewModelsValueHandler)
				.store(in: &subscriptions)
			
			let stateValueHandler: (ChooseProductViewModelState) -> Void = { [weak self] state in
				switch state {
				case .loading:
					self?.contentView.startLoading()
				case .finishedLoading:
					self?.contentView.finishLoading()
				case .error(let error):
					self?.contentView.finishLoading()
					self?.showError(error)
				}
			}
			
			viewModel.$state
				.receive(on: RunLoop.main)
				.sink(receiveValue: stateValueHandler)
				.store(in: &subscriptions)
		}
		
		bindViewToViewModel()
		bindViewModelToView()
	}
	
	private func showError(_ error: Error) {
		let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
		let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
			self.dismiss(animated: true, completion: nil)
		}
		alertController.addAction(alertAction)
		present(alertController, animated: true, completion: nil)
	}
}

extension ChooseProductController: UITableViewDataSource, UITableViewDelegate {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.chooseProductViewModels.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: ChooseProductCellItem.identifier, for: indexPath)
		
		guard let productCell = dequeuedCell as? ChooseProductCellItem else {
			fatalError("Could not dequeue a cell")
		}
		
		productCell.viewModel = viewModel.chooseProductViewModels[indexPath.row]
		return productCell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		let id = viewModel.chooseProductViewModels[indexPath.row].id
		self.handlerSelectedProduct?(id)
	}
}
