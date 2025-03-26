//
//  SearchNewsController.swift
//  KipasKipas
//
//  Created by movan on 16/12/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine

enum SectionSearchNews {
	case news
}

protocol SearchNewsDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: SearchNewsModel.ViewModel)
}

final class SearchNewsController: UIViewController, Displayable, SearchNewsDisplayLogic {
	
	private let mainView: SearchNewsView
	private var interactor: SearchNewsInteractable!
	private var router: SearchNewsRouting!
	private lazy var dataSource: UICollectionViewDiffableDataSource<SectionSearchNews, AnyHashable>! = nil
	private var subscriptions: Set<AnyCancellable> = []
	private var page = 0
	
	init(mainView: SearchNewsView, dataSource: SearchNewsModel.DataSource) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		interactor = SearchNewsInteractor(viewController: self, dataSource: dataSource)
		router = SearchNewsRouter(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		bindDataSource()
		self.navigationController?.interactivePopGestureRecognizer?.delegate = self
	
		mainView.searchBar.textPublisher
			.debounce(for: 1, scheduler: RunLoop.current)
			.removeDuplicates()
			.assign(to: \.text, on: self.interactor.dataSource)
			.store(in: &subscriptions)

			self.interactor.dataSource.$text.sink { [weak self] in
				self?.interactor.doRequest(.searchNews(by: $0, page: 0))
			}.store(in: &self.subscriptions)
		
		createNotificationObservers()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func bindDataSource() {
		dataSource = UICollectionViewDiffableDataSource<SectionSearchNews, AnyHashable>(collectionView: mainView.collectionView) {
			(collectionView, index, object) -> UICollectionViewCell? in
			
			switch object {
			case let object as NewsCellViewModel:
				let cell = collectionView.dequeueReusableCustomCell(with: NewsCell.self, indexPath: index)
				
				cell.setUpCell(item: object)
				cell.likeHandler = {
					
					if AUTH.isLogin() {
						if cell.isLike {
							cell.unlike(id: object.id ?? "", status: "unlike")
						} else {
							cell.like(id: object.id ?? "", status: "like")
						}
					} else {
						self.showPopUp()
					}
				}
				
				cell.commentHandler = {
					if AUTH.isLogin() {
						let dataSource = CommentModel.DataSource()
						dataSource.id = object.id
						dataSource.postId = object.postId
                        guard let id = object.id else { return }
                        let comment = CommentDataSource(id: id)
                        let commentController = CommentViewController(commentDataSource: comment)
                        commentController.bindNavigationBar(.get(.commenter), true)
                        commentController.hidesBottomBarWhenPushed = true
                        
						self.navigationController?.pushViewController(commentController, animated: false)
					} else {
						self.showPopUp()
					}
					
				}
				
				cell.shareHandler = {
					self.handleShare(item: object)
				}
				
				
				return cell
			default:
				return nil
			}
		}
		
		let snapshot = createSnapshot()
		dataSource.apply(snapshot, animatingDifferences: false)
	}
	
	private func handleShare(item : NewsCellViewModel) {
		
		let text =  "KIPASKIPAS NEWS \n\n\(item.title ?? "") \n\n\nKlik link berikut untuk membuka tautan: news.kipaskipas.com"
		
		let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
		
		self.present(activityController, animated: true, completion: nil)
	}
	
	func showPopUp(){
		let popup = AuthPopUpViewController(mainView: AuthPopUpView())
		popup.modalPresentationStyle = .overFullScreen
		present(popup, animated: false, completion: nil)
        
        popup.handleWhenNotLogin = {
            popup.dismiss(animated: false, completion: nil)
        }
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let object = dataSource.itemIdentifier(for: indexPath)
		
		switch object {
		case let object as NewsCellViewModel:
            let viewModel = NewsDetailViewModel(networkModel: FeedNetworkModel(), id: object.id ?? "", newsDetail: object.newsDetail)
            let controller = NewsDetailController(viewModel: viewModel)
            controller.bindNavigationBar("", true)
			bindNavigationBar()
			controller.hidesBottomBarWhenPushed = true
			controller.index = indexPath
			self.navigationController?.pushViewController(controller, animated: true)
		default:
			break
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
				nextPage()
		}
	}
	
	func nextPage(){
		if self.interactor.dataSource.data.count > 9 {
			self.page = self.page + 1
			self.interactor.dataSource.$text.sink { [weak self] in
			 self?.interactor.doRequest(.searchNewsPaging(by: $0, page: self!.page))
		 }.store(in: &subscriptions)
		}
	}
	
	private func createSnapshot() -> NSDiffableDataSourceSnapshot<SectionSearchNews, AnyHashable> {
		var snapshot = NSDiffableDataSourceSnapshot<SectionSearchNews, AnyHashable>()
		snapshot.appendSections([.news])
		snapshot.appendItems(self.interactor.dataSource.data)
		
		return snapshot
	}
	
	private func updateUI() {
		let snapshot = createSnapshot()
		dataSource.apply(snapshot, animatingDifferences: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		bindNavigationBar() 
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.collectionView.delegate = self
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	
	// MARK: - SearchNewsDisplayLogic
	func displayViewModel(_ viewModel: SearchNewsModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
			
			case .news(let viewModel):
				self.displayNews(viewModel)
			}
		}
	}
}


// MARK: - SearchNewsViewDelegate
extension SearchNewsController: SearchNewsViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate {
	
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
}


// MARK: - Private Zone
private extension SearchNewsController {
	
	func displayNews(_ viewModel: [NewsCellViewModel]) {
		self.updateUI()
	}
	
	
}

extension SearchNewsController {
	

	
	func createNotificationObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(updateLikeCell(notification:)), name: newsCellUpdateNotifKey, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateCommentCounterCell(notification:)), name: newsCellUpdateCommentNotifKey, object: nil)
	}
	
	@objc
	func updateLikeCell(notification: NSNotification){
		if let isLike = notification.userInfo?["isLike"] as? Bool, let index = notification.userInfo?["index"] as? IndexPath, let likes = notification.userInfo?["likes"] as? Int {
			
			var snapshot = NSDiffableDataSourceSnapshot<SectionSearchNews, AnyHashable>()
			snapshot.appendSections([.news])
			snapshot.deleteItems(interactor.dataSource.data)
			
			var news = interactor.dataSource.data[index.row]
			news.isLike = isLike
			news.likes = likes
			interactor.dataSource.data.remove(at: index.row)
			interactor.dataSource.data.insert(news, at: index.row)
			
			snapshot.appendItems(interactor.dataSource.data)
			dataSource.apply(snapshot, animatingDifferences: false)
		}
	}
	
	@objc
	func updateCommentCounterCell(notification: NSNotification){
		if let comment = notification.userInfo?["comments"] as? Int, let index = notification.userInfo?["index"] as? IndexPath {
			
			var snapshot = NSDiffableDataSourceSnapshot<SectionSearchNews, AnyHashable>()
			snapshot.appendSections([.news])
			snapshot.deleteItems(interactor.dataSource.data)
			
			var news = interactor.dataSource.data[index.row]
			news.comment = comment
			interactor.dataSource.data.remove(at: index.row)
			interactor.dataSource.data.insert(news, at: index.row)
			
			snapshot.appendItems(interactor.dataSource.data)
			dataSource.apply(snapshot, animatingDifferences: false)
		}
	}

}
