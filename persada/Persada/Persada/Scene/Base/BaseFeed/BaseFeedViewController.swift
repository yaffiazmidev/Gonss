//
//  BaseFeedViewController.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 19/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import ContextMenu

protocol NewSelebDisplayLogic where Self: UIViewController {

	func displayViewModel(_ viewModel: FeedModel.ViewModel)
}

protocol BaseFeedViewControllerDelegate: class {
	func calculate(comment value: Int)
	func calculateLike(like value: Int)
	func handleCommentClicked(feed: Feed, row: Int)
	func handleShareFeedClicked(feed: Feed)
    func handleLikeFeedClicked(feed: Feed, row: Int)
	func handleProfileClicked(id: String, type: String)
}

public class BaseFeedViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AlertDisplayer {

    let popup = AuthPopUpViewController(mainView: AuthPopUpView())
	let mainView: BaseFeedView
	private var basePresenter: BaseFeedPresenter!
	var cachedHeight: [Int : CGFloat] = [:]
    private let networkReport = ReportNetworkModel()
	weak var delegate: BaseFeedViewControllerDelegate?

	required init(view: BaseFeedView) {
		self.mainView = view
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupFeedPresenter(presenter: BaseFeedPresenter) {
		self.basePresenter = presenter
		setupPresenter(presenter: basePresenter)
	}

	public override func viewDidLoad() {
		view.backgroundColor = .white
		mainView.tableView.separatorStyle = .none


		NotificationCenter.default.addObserver(self,
																					 selector: #selector(self.appEnteredFromBackground),
																					 name: Notification.Name.NSExtensionHostWillEnterForeground, object: nil)

		setupObserveable()
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	public override func viewWillDisappear(_ animated: Bool) {
		pausePlayeVideos(pause: true)
	}


	public override func viewDidAppear(_ animated: Bool) {
		pausePlayeVideos()
		perform(#selector(self.pausePlayeVideos), with: nil, afterDelay: TimeInterval(1))
		super.viewDidAppear(animated)
	}

	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return basePresenter.feedsDataSource.value[collectionView.tag].post?.medias?.count ?? 0
	}

	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let cell = collectionView.dequeueReusableCustomCell(with: NewSelebCarouselCell.self, indexPath: indexPath)

		if let medias = basePresenter.feedsDataSource.value[collectionView.tag].post?.medias {
			cell.configure(item: medias[indexPath.row])
		}

		return cell
	}

	public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: mainView.tableView.frame.width, height: 300)
	}

	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		mainView.tableView.visibleCells.forEach { cell in
			guard let cell = cell as? BaseFeedMultipleTableViewCell else {return}
			cell.pageControl.currentPage = indexPath.row
		}
	}
}


private extension BaseFeedViewController {

	@objc func appEnteredFromBackground() {
		ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: mainView.tableView, appEnteredFromBackground: true)
	}

	func refreshRow(_ row: Int) {
		self.mainView.tableView.beginUpdates()
		if !basePresenter.expandedRow.contains(row) {
			basePresenter.expandedRow.append(row)
		}
		self.mainView.tableView.endUpdates()
	}

	func checkExpandedRow(_ row: Int) -> Bool {
		return basePresenter.expandedRow.contains(row)
	}

	func getCachedHeight(indexPath: Int) -> CGFloat {

		if 	let height = cachedHeight[indexPath] {
			return height
		}
		let feed = basePresenter.feedsDataSource.value[indexPath]
		if let media = feed.post?.medias {
			if media.count > 1 {
				let height: Int = 1920
				let width: Int = 1920
				let newHeight = (((UIScreen.main.bounds.width * CGFloat(height)) / CGFloat(width)))

				cachedHeight[indexPath] = newHeight
			} else if let med = media.first {
				// calculate the height for view
				let height: Int = Int(med.metadata?.height ?? "1920") ?? 1920
				let width: Int = Int(med.metadata?.width ?? "1920") ?? 1920
				var newHeight = (((UIScreen.main.bounds.width * CGFloat(height)) / CGFloat(width))) * 0.93
				let acceptableHeight = UIScreen.main.bounds.height*0.7

				if newHeight > acceptableHeight {
					newHeight = acceptableHeight
				}

				cachedHeight[indexPath] = newHeight

			}
		}

		return cachedHeight[indexPath] ?? 0

	}

}

extension BaseFeedViewController: ReportFeedDelegate {
    func reported() {
        DispatchQueue.main.async {
            let popup = ReportPopupViewController(mainView: ReportPopupView())
            popup.modalPresentationStyle = .overFullScreen
            self.present(popup, animated: false, completion: nil)
        }
    }
}

extension BaseFeedViewController: UITableViewDelegate {
	public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let videoCell = cell as? ASAutoPlayVideoLayerContainer, let _ = videoCell.videoURL {
			ASVideoPlayerController.sharedVideoPlayer.removeLayerFor(cell: videoCell)
		}
	}

	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		pausePlayeVideos()
	}

	public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			pausePlayeVideos()
		}
	}

	@objc func pausePlayeVideos(pause: Bool = false){
		ASVideoPlayerController.sharedVideoPlayer.pausePlayeVideosFor(tableView: mainView.tableView, appEnteredFromBackground: false, stopVideo: pause)
	}

}

extension BaseFeedViewController {

	internal func handleReport(_ id: String, _ accountId: String, _ imageUrl: String) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: .get(.report), style: .default , handler:{ _ in
            self.networkReport.checkIsReportExist(.reportsExist(id: id)) { result in
                switch result {
                    case .success(let isExist):
                        DispatchQueue.main.async {
                            if !(isExist.data ?? false) {
                                self.showReportController(id: id, imageUrl: imageUrl, accountId: accountId)
                            } else {
                                self.displayAlert(with: .get(.report), message: .get(.accountReported), actions: [UIAlertAction(title: .get(.ok), style: .cancel)])
                            }
                        }
                    case .failure(let err):
                        DispatchQueue.main.async {
                            self.displayAlert(with: .get(.error), message: err?.localizedDescription ?? "", actions: [UIAlertAction(title: .get(.ok), style: .cancel)])
                        }
                }

            }
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        if AUTH.isLogin(){
            present(actionSheet, animated: true, completion: nil)
        } else {
            let popup = AuthPopUpViewController(mainView: AuthPopUpView())
            popup.modalPresentationStyle = .overFullScreen
            present(popup, animated: false, completion: nil)
            
        }
    }

    private func showReportController(id: String, imageUrl: String, accountId: String) {
        let reportController = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, networkModel: ReportNetworkModel()))
        reportController.delegate = self
        self.present(reportController, animated: true, completion: nil)
    }

	private func getSingleFeedCell(tv: UITableView, row: Int, data: Feed) -> BaseFeedTableViewCell2 {

		let cell = tv.dequeueReusableCustomCell(with: BaseFeedTableViewCell2.self, indexPath: IndexPath.init(row: row, section: 0))

		cell.row = row

		cell.handler = { row in
			self.refreshRow(row)
		}

		cell.profileHandler = { (id, type) in
			self.delegate?.handleProfileClicked(id: id, type: type)
		}

		cell.updateFeed = { (feed) in
            self.basePresenter.saveFeed(feed: feed)
		}

		cell.commentHandler = { item in
			self.delegate?.handleCommentClicked(feed: item, row: row)
		}
        
        cell.likeHandler = { item in
            self.delegate?.handleLikeFeedClicked(feed: item, row: row)
        }

		cell.reportHandler = self.handleReport(_:_:_:)
		cell.sharedHandler = {
			self.delegate?.handleShareFeedClicked(feed: data)
		}

		cell.mentionHandler = { (text, type) in
			if type == .mention {
				// todo mention
			}
		}

		cell.setup(feed: data, expanded: self.checkExpandedRow(row), height: self.getCachedHeight(indexPath: row))

		return cell
	}

	private func getMultipleFeedCell(tv: UITableView, row: Int, data: Feed) -> BaseFeedMultipleTableViewCell {
		let cell = tv.dequeueReusableCustomCell(with: BaseFeedMultipleTableViewCell.self, indexPath: IndexPath.init(row: row, section: 0))
		cell.row = row

		cell.handler = { row in
			self.refreshRow(row)
		}

		cell.profileHandler = { (id, type) in
			self.delegate?.handleProfileClicked(id: id, type: type)
		}

		cell.updateFeed = { (feed) in
			self.basePresenter.saveFeed(feed: feed)
		}

		cell.commentHandler = { item in
			self.delegate?.handleCommentClicked(feed: item, row: row)
		}

		cell.reportHandler = self.handleReport(_:_:_:)
		cell.sharedHandler = {
			self.delegate?.handleShareFeedClicked(feed: data)
		}

		cell.mentionHandler = { (text, type) in
			if type == .mention {
				// todo mention
			}
		}
		cell.setup(feed: data, expanded: self.checkExpandedRow(row))
		return cell
	}

	private func setupObserveable() {
		self.mainView.tableView.rx.setDelegate(self).disposed(by: disposeBag)

		basePresenter.loadingState.asObservable().map{!$0}.bind(to: mainView.footerView.rx.isHidden).disposed(by: disposeBag)

		basePresenter.loadingState.asObservable().subscribe { bool in
			if (!bool){
				self.mainView.refreshController.endRefreshing()
			}
		} onError: { err in
			print(err)
		}.disposed(by: disposeBag)


		basePresenter.feeds?.drive(self.mainView.tableView.rx.items){ (tv, row, item) -> UITableViewCell in

			if (item.post?.medias?.count ?? 0) <= 1 {
				return self.getSingleFeedCell(tv: tv, row: row, data: item)
			} else {
				return self.getMultipleFeedCell(tv: tv, row: row, data: item)
			}
		}.disposed(by: disposeBag)

		basePresenter.loadingState.asObservable().subscribe { bool in
			if (!bool){
				self.mainView.refreshController.endRefreshing()
			}
		} onError: { err in
			print(err)
		}.disposed(by: disposeBag)

		mainView.tableView.rx.willDisplayCell
			.subscribe(onNext:  { cell, indextPath in

				guard let cell = cell as? BaseFeedMultipleTableViewCell else {return}
				if (cell.feed?.post?.medias?.count ?? 0) > 1 {
					cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indextPath.row)
				}
			}).disposed(by: disposeBag)
	}
}
