//
//  ChannelDetailViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 31/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import RxSwift
import RxCocoa
import ContextMenu

protocol ChannelDetailDisplayLogic where Self: UIViewController {

	func displayViewModel(_ viewModel: ChannelDetailModel.ViewModel)
}

class ChannelDetailViewController: UIViewController, Displayable, ChannelDetailDisplayLogic {

	static let serialBackground = SerialDispatchQueueScheduler.init(qos: .background)
	static let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)

	private let mainView: ChannelDetailView
	private var interactor: ChannelDetailInteractable!
	private var router: ChannelDetailRouting!
	private let dataSource: BehaviorRelay<[Feed]> = BehaviorRelay(value: [])

	required init(mainView: ChannelDetailView, dataSource: ChannelDetailModel.DataSource) {
		self.mainView = mainView
		super.init(nibName: nil, bundle: nil)
		interactor = ChannelDetailInteractor(viewController: self, dataSource: dataSource)
		router = ChannelDetailRouter(self)
	}

	let disposeBag = DisposeBag()
	var loadNextPage = PublishSubject<Void>()
	let error = PublishSubject<Swift.Error>()
	let loading = BehaviorRelay<Bool>(value: false)
	var offset:Int = 0
	var maincollectionView: UICollectionView!

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.navigationBar.tintColor = .black
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupRX()
	}

	override func loadView() {
		mainView.pinterestLayout.delegate = self
		view = mainView
		view.backgroundColor = .white
		mainView.delegate = self
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}


	// MARK: - ChannelDetailDisplayLogic
	func displayViewModel(_ viewModel: ChannelDetailModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {

				case .doSomething(let viewModel):
					self.displayDoSomething(viewModel)
			}
		}
	}
	
	private func reportHandler(_ id: String, _ accountId: String, _ imageUrl: String) {
		let reportMenu = ReportMenuController()
		let rows = accountId == getIdUser() ? 2 : 1
		reportMenu.source(id: id, accountId: accountId, imageUrl: imageUrl, rows: rows)
		ContextMenu.shared.show(
			sourceViewController: self,
			viewController: reportMenu,
			options: ContextMenu.Options(menuStyle: .minimal, hapticsStyle: .medium)
		)
	}
	
	private func commentHandler(_ data: Feed) {
		guard let id = data.id else {
			return
		}
		
        
        let comment = CommentDataSource(id: id)
        let controller = CommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true
		
		self.navigationController?.pushViewController(controller, animated: false)
	}
}


// MARK: - Private Zone
private extension ChannelDetailViewController {

	func displayDoSomething(_ viewModel: NSObject) {
		print("Use the mainView to present the viewModel")
	}

	func setupRX() {
		let id = interactor.dataSource.id ?? interactor.dataSource.channelId!
		requestFeed(id: id)

		mainView.collectionView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
			if indexPath.row == self.dataSource.value.count - 1 && self.loading.value == false {
				self.requestFeed(id: id)
			}
		}).disposed(by: disposeBag)

//		dataSource.asObservable().bind(to: mainView.collectionView.rx.items(cellIdentifier: ChannelDetailView.selebCellId, cellType: FeedItemCell.self)) {row,data,cell in
//			print(data)
//			let medias = data.post?.medias ?? []
//			cell.configureMedias(medias)
//
//			cell.configureItem(data)
//			cell.reportHandler = self.reportHandler(_:_:_:)
//			cell.commentHandler = self.commentHandler(_:)
//			cell.likeHandler = { (id, status) in
//				cell.bind(viewModel: FeedItemCellViewModel(network: FeedNetworkModel()))
//				
//				if status == "like" {
//					cell.like(status: status)
//				} else if ( status == "unlike") {
//					cell.unlike(status: status)
//				}
//			}
//			
//			cell.sharedHandler = {
//				guard let post = data.post, let text = post.postDescription else {
//					return
//				}
//				
//				let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
//				self.present(activityController, animated: true, completion: nil)
//			}
//
//		}
//		.disposed(by: disposeBag)

		loadNextPage.onNext(())

	}

	func setupNavigation() {
		self.navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	func requestLike(id: String, status: String, index: Int) {

		interactor.requestLike(id: id, status: status)
			.retry(3)
			.subscribeOn(ChannelDetailViewController.concurrentBackground)
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { response in
				var response = response
				
				self.mainView.collectionView.performUsingPresentationValues {
				}
			}).disposed(by: disposeBag)
	}

	func requestFeed(id: String) {
		self.loading.accept(true)
		loading.bind(to: mainView.loadingView.rx.isAnimating).disposed(by: disposeBag)

		if let feed = interactor.dataSource.feed {
			dataSource.accept([feed])
		}

		let item = interactor.dataSource.id != nil ? interactor.requestChannelPost(id, page: offset) : interactor.requestChannelId(id: id, page: offset)
		item
			// Set 3 attempts to get response
			.retry(3)
			// Subscribe in background thread
			.subscribeOn(ChannelDetailViewController.concurrentBackground)
			// Observe in main thread
			.observeOn(MainScheduler.instance)
			.subscribe(onNext: { feed in
				var feed = feed
				if self.offset == 0 {
					feed.remove(at: 0)
					self.mainView.setupRefresh()
				}
				self.dataSource.accept(self.dataSource.value + feed)
				self.loading.accept(false)
				self.offset += 1
				self.mainView.refreshController.endRefreshing()
			}).disposed(by: disposeBag)

	}
}

extension ChannelDetailViewController : ChannelDetailViewDelegate, PinterestLayoutDelegate {
	func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
		let item = dataSource.value[indexPath.row].post?.medias?.first
		let heightImage = Double(item?.metadata?.height ?? "") ?? 100
		let widthImage = Int(item?.metadata?.height ?? "") ?? 100
		let height = heightImage < 500 ? Double(heightImage) : Double(Int(heightImage) / widthImage + 3 * 180)
		let width = Double(self.view.bounds.width)
		return CGSize(width: width, height: height)
	}
	
	func refreshUI() {
		guard let id = interactor.dataSource.channelId else {return}
		requestFeed(id: id)
		offset = 0
		var emptyDataSource = self.dataSource.value
		emptyDataSource.removeAll()
		self.dataSource.accept(emptyDataSource)
	}
}
