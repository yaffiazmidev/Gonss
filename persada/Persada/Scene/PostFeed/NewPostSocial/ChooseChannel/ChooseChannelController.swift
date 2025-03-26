//
//  ChooseChannelController.swift
//  Persada
//
//  Created by movan on 03/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CombineDataSources

protocol ChooseChannelDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: ChooseChannelModel.ViewModel)
}

final class ChooseChannelController: UIViewController, Displayable, ChooseChannelDisplayLogic {
	
	private let mainView: ChooseChannelView
	private var interactor: ChooseChannelInteractable!
	private var router: ChooseChannelRouting!
	var delegate: PostControllerDelegate?
	private var subscriptions = Set<AnyCancellable>()
    private var subscriptionsPaging = Set<AnyCancellable>()
	
	init(mainView: ChooseChannelView, dataSource: ChooseChannelModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = ChooseChannelInteractor(viewController: self, dataSource: dataSource)
		router = ChooseChannelRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		refresh()
        
        self.mainView.collectionView.willDisplayCellPublisher.sink { cell, index in
            let items = self.interactor.dataSource.data
            if index.row == items.count - 1 && items.count < items.count + 10 {
                let searchText = self.interactor.dataSource.channelName
                self.interactor.dataSource.page = self.interactor.dataSource.page + 1
                self.interactor.doRequest(.fetchChannel(text: searchText, page: self.interactor.dataSource.page))
            }
        }.store(in: &subscriptions)
        
        self.interactor.dataSource.$data
            .bind(subscriber: mainView.collectionView.itemsSubscriber(cellIdentifier: ChooseChannelView.ViewTrait.cellId, cellType: ChooseChannelCell.self, cellConfig: { cell, _, object in
                
                cell.data = object
                
            }))
            .store(in: &subscriptions)
        
        self.interactor.dataSource.$data
            .receive(on: DispatchQueue.main)
            .map{ !($0.isEmpty && !self.mainView.searchBar.text.isNilOrEmpty) }
            .assign(to: \.isHidden, on: self.mainView.emptyView)
            .store(in: &subscriptions)
        
        self.interactor.dataSource.$channelName.sink { [weak self] in
            self?.interactor.dataSource.data.removeAll()
            self?.interactor.dataSource.page = 0
            self?.interactor.doRequest(.fetchChannel(text: $0, page: 0))
            }.store(in: &subscriptions)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(.get(.following))
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationItem.title = .get(.chooseChannel)
	}
	
	override func loadView() {
		view = mainView
		mainView.backgroundColor = .white
		mainView.delegate = self
        mainView.searchBar.delegate = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - ChooseChannelDisplayLogic
	func displayViewModel(_ viewModel: ChooseChannelModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {

			case .channels(let viewModel):
				self.displayChannels(viewModel)
			}
		}
	}
}


// MARK: - ChooseChannelViewDelegate
extension ChooseChannelController: ChooseChannelViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		mainView.searchBar.textPublisher
            .debounce(for: 0.5, scheduler: RunLoop.main)
			.removeDuplicates()
			.assign(to: \.channelName, on: self.interactor.dataSource)
			.store(in: &subscriptions)
		
		
	}
	
	func refresh() {
		self.interactor.dataSource.page = 0
		let searchText = interactor.dataSource.channelName
		self.interactor.doRequest(.fetchChannel(text: searchText, page: 0))
		
		
		self.mainView.collectionView.didSelectItemPublisher.sink { index in
			let item = self.interactor.dataSource.data[index.row]
			self.dismiss(item)
		}.store(in: &subscriptions)
		
		self.interactor.dataSource.$searching.sink { [weak self] searching in
			searching ? self?.mainView.refreshControl.beginRefreshing() : self?.mainView.refreshControl.endRefreshing()
		}.store(in: &subscriptions)
		
		self.mainView.searchBar.returnPublisher.sink {
			self.mainView.searchBar.resignFirstResponder()
		}.store(in: &subscriptions)

	}
	
	func dismiss(_ channel: Channel?) {
		if let chan = channel {
            self.router.routeTo(.dismiss)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.setChannel(channel: chan)
            }
		}
	}
}


// MARK: - Private Zone
private extension ChooseChannelController {

	func displayChannels(_ viewModel: [Channel]) {
        let array = self.interactor.dataSource.data + viewModel
        self.interactor.dataSource.data = array.uniqued()
		self.mainView.refreshControl.endRefreshing()
		self.mainView.collectionView.reloadData()
	}
}

extension Array where Element: Hashable {
    func uniqued() -> Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
