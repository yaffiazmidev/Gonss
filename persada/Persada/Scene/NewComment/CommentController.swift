//
//  CommentController.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import ContextMenu
import Combine
import CombineCocoa
import RxSwift
import RxCocoa

let likeFeedCommentNotifKey = Notification.Name(rawValue: "likeChangeFromDetailCommentFeedKey")

protocol CommentDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: CommentModel.ViewModel)
}

protocol CommentControllerDelegate: AnyObject {
	func add(subcomment value: Int)
	func refreshComment()
}

class CommentController: UIViewController, Displayable, CommentDisplayLogic {
	
	let mainView: CommentView
	let _loadingState = BehaviorRelay<Bool>(value: false)
	var loadingState: Driver<Bool> {
		return _loadingState.asDriver()
	}
	var alertController: UIAlertController? = nil
	var interactor: CommentInteractable!
	var router: CommentRouting!
	var presenter: CommentPresenter!
	private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
	private let disposeBag: DisposeBag = DisposeBag()
	weak var delegate: BaseFeedViewControllerDelegate?
	
	var sizeOfHeader: CGSize = CGSize(width: 0, height: 0)
	var isDeleted = false
	var row = 0
	var contentLoaded = false
	var commentLoaded = false
	var visibel = false
	var isCalled = false
	
	var fromNewsList = false
	var fromNewsDetail = false
	var newsListIndex: IndexPath?
	
	var deleteCommentID = ""
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	@Published var commentText: String? = ""
	
	lazy var validateButton = $commentText.map { (value: String?) -> Bool in
		if ((value?.count ?? 0) > 1) && self.mainView.commentTextField.nameTextField.textColor != .placeholder  {
			let imageIcon = UIImage(named: String.get(.iconFeatherSend))
			self.mainView.submitButton.setImage(imageIcon, for: .normal)
			return true
		} else {
			let imageIcon = UIImage(named: String.get(.iconFeatherSendGray))
			self.mainView.submitButton.setImage(imageIcon, for: .normal)
			return false
		}
		
	}.eraseToAnyPublisher()
	
	required init(mainView: CommentView, dataSource: CommentModel.DataSource) {
		self.mainView = mainView
		self.row = dataSource.row ?? 0
		
		super.init(nibName: nil, bundle: nil)
		interactor = CommentInteractor(viewController: self, dataSource: dataSource)
		router = CommentRouter(self)
		presenter = CommentPresenter(self)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tabBarController?.tabBar.isHidden = true
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		tabBarController?.tabBar.isHidden = false
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		presenter.deleted.bind { (deleted) in
			if deleted {
				self.router.routeTo(.dismissComment)
			}
		}.disposed(by: disposeBag)
		
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.fetchHeaderComment(id: id))
		
		mainView.hideView()
		NotificationCenter.default.addObserver(self,
																					 selector: #selector(self.keyboardNotification(notification:)),
																					 name: UIResponder.keyboardWillChangeFrameNotification,
																					 object: nil)
		

		let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboardComment))
		self.mainView.collectionView.addGestureRecognizer(tap)
		
		self.navigationController?.disableHideKeyboardTappedAround()
		
		
		self.loadingState.asObservable().bind { bool in
			if bool {
				self.loadinHubShow()
			} else {
				self.loadinHubDismiss()
			}
		}.disposed(by: disposeBag)
		
		self.mainView.commentTextField.nameTextField.textPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: \.commentText, on: self)
			.store(in: &subscriptions)
		
		validateButton
			.receive(on: RunLoop.main)
			.assign(to: \.isEmpty, on: self.mainView.submitButton)
			.store(in: &subscriptions)
	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self
		mainView.isUserInteractionEnabled = true
	}
	
	
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	@objc func dismissKeyboardComment() {
		view.endEditing(true)
	}
	
	@objc func keyboardNotification(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		
		let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
		let endFrameY = endFrame?.origin.y ?? 0
		let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
		let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
		let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
		let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
		
		if endFrameY >= UIScreen.main.bounds.size.height {
			self.mainView.keyboardHeightLayoutConstraint?.constant = 0.0
		} else {
			self.mainView.keyboardHeightLayoutConstraint?.constant = -(endFrame?.size.height ?? 0.0)
		}
		
		UIView.animate(
			withDuration: duration,
			delay: TimeInterval(0),
			options: animationCurve,
			animations: { self.view.layoutIfNeeded() },
			completion: nil)
	}
	
	// MARK: - CommentDisplayLogic
	func displayViewModel(_ viewModel: CommentModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {
			case .comment(let viewModel):
				self.displayComment(viewModel)
			case .like(let viewModel):
				self.changeLike(viewModel)
			case .addComment(let viewModel):
				self.addComment(viewModel)
			case .header(let viewModel):
				self.displayHeaderComment(viewModel)
			case .paginationComment(let viewModel):
				self.displayPaginationComment(viewModel)
			case .mention(let viewModel):
				self.displayMention(viewModel)
			case .errorHeader(error: let error):
				self.errorHeader(error: error)
			case .deleteComment(_):
				self.deleteCommentAction()
			}
		}
	}
	
	func deleteCommentAction(){
		let data = self.interactor.dataSource.data.filter { (comment) -> Bool in
			comment.id != deleteCommentID
		}
		
		interactor.dataSource.data = data
		
		mainView.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
	}
	
	func errorHeader(error: Error){
		isDeleted = true
		mainView.showError(error: error)
	}
}


// MARK: - CommentViewDelegate
extension CommentController: CommentViewDelegate, AlertDisplayer, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, CommentControllerDelegate {
	
	func refreshComment() {
		self.interactor.dataSource.dataHeader.comments? -= 1
		refresh()
	}
	
	func add(subcomment value: Int) {
		guard let index = interactor.dataSource.index else {
			return
		}
		
		let indexPath = IndexPath(item: index, section: 0)
		
		mainView.collectionView.performBatchUpdates({
			self.interactor.dataSource.data[index].comments! += value
			self.mainView.collectionView.reloadItems(at: [indexPath])
			self.mainView.collectionView.superview?.layoutIfNeeded()
		}, completion: nil)
	}
	
	func refresh() {
		let id = interactor.dataSource.id ?? ""
		interactor.setPage(page: 0)
		interactor.doRequest(.fetchHeaderComment(id: id))
	}
	
	func subcomment(id: String, data: CommentHeaderCellViewModel) {
		router.routeTo(.subcomment(postId: interactor.dataSource.postId ?? "", id: id, dataSource: data))
	}
	
	func like(id: String, status: String, index: Int) {
		let postId = interactor.dataSource.postId ?? ""
		interactor.doRequest(.like(postId: postId, id: id, status: status, index: index))
	}
	
	func pagination(total: Int) {
		//		if let page = interactor.dataSource.page, (total/10) >= page {
		//			interactor.setPage(page: page + 1)
		//			interactor.doRequest(.fetchComment(id: interactor.dataSource.id ?? "", page: page))
		//		}
	}
	
	func whenClickSubmit() {
		_loadingState.accept(true)
		if mainView.commentTextField.nameTextField.text?.isEmpty ?? false {
			let title = "Warning"
			let action = UIAlertAction(title: "OK", style: .default)
			self.displayAlert(with: title , message: "Empty Message", actions: [action])
		} else {
			let id = interactor.dataSource.id ?? ""
			let text = mainView.commentTextField.nameTextField.text ?? ""
			interactor.doRequest(.addComment(id: id, value: text))
			dismissKeyboardComment()
		
		}
	}
	
	func dismiss() {
		router.routeTo(.dismissComment)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interactor.dataSource.data.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: CommentCell.self, indexPath: indexPath)
		let row = indexPath.row
		let items = self.interactor.dataSource.data
		
		let item = items[row]
		
		cell.item = item
		
		cell.reportHandler = { (id, accountId, imageUrl) in
			self.handleReportWithoutPopUp(id, accountId, imageUrl)
		}
		
		cell.profileHandle = delegate?.handleProfileClicked
		
		cell.likeHandler = { (id, status) in
            cell.configureStatusLike(status: cell.item?.isLike ?? false)
			self.interactor.dataSource.index = row
			self.like(id: id, status: status, index: row)
		}
		
		cell.replyHandler = { id in
			self.subcomment(id: id, data:
												CommentHeaderCellViewModel(description: item.value ?? "", username: item.account?.username ?? "", imageUrl: item.account?.photo ?? "", date: item.createAt ?? 0, feed: self.interactor.dataSource.dataHeader)
			)
			self.interactor.dataSource.index = row
		}
		
		cell.profileHandle = { id, type in
			self.router.routeTo(.showProfile(id: id, type: type))
		}
		
		if indexPath.row == items.count - 1 { // last cell
			self.pagination(total: items.count)
		}
		
		return cell
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		return sizeOfHeader.height == 0 ? CGSize(width: 300, height: 300) : sizeOfHeader
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let cell = collectionView.dequeueReusableSupplementaryView(ofKind: CommentView.className, withReuseIdentifier: CommentHeaderView.className, for: IndexPath(row: 0, section: 0)) as! CommentHeaderView
		
		guard let dataHeader = self.interactor.dataSource.dataHeader else {
			return cell
		}
		if isCalled {
		
		cell.setup(item: dataHeader)
		}
		isCalled = true
		cell.comment = self.interactor.dataSource.headerItems
		cell.mentionHandler = { [weak self] (text) in
			self?.interactor.doRequest(.mention(word: text))
		}
		cell.hashtagHandler = { [weak self] (text) in
			self?.router.routeTo(.hashtag(hashtag: text))
		}

		cell.reportHandler = { (id, accountId, imageUrl) in
			self.handleReport(id, accountId, imageUrl)
		}
		cell.sharedHandler = { () in
			let text =  "\(dataHeader.account?.name ?? "KIPASKIPAS") \n\n\(dataHeader.post?.postDescription ?? "") \n\n\nKlik link berikut untuk membuka tautan: \(APIConstants.webURL)/feed/\(dataHeader.id ?? "")"
			self.router.routeTo(.shared(text: text))
		}
		
		cell.likeHandler = { feed in
			self.presenter.updateFeedLike(feed: feed)
			self.interactor.dataSource.dataHeader = feed
			let data = ["feed" : feed, "row": self.row] as [String : Any]
			NotificationCenter.default.post(name: likeFeedCommentNotifKey, object: nil, userInfo: data)

			let likes = feed.likes
			if self.fromNewsList {
				let dataDict : [String:Any] = ["index" : self.newsListIndex!, "isLike" : feed.isLike!, "likes": likes ?? 0 + 1]
				NotificationCenter.default.post(name: newsCellUpdateNotifKey, object: nil, userInfo: dataDict)
			}

			if self.fromNewsDetail {
				let dataDict : [String:Any] = ["index" : self.newsListIndex!, "isLike" : feed.isLike!, "likes": likes ?? 0 + 1]
				NotificationCenter.default.post(name: newsDetailUpdateNotifKey, object: nil, userInfo: dataDict)
			}
		}
		
		cell.profileHandler = delegate?.handleProfileClicked
		self.sizeOfHeader = cell.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height),
																										 withHorizontalFittingPriority: .required, // Width is fixed
																										 verticalFittingPriority: .fittingSizeLevel)
        
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
		
        if  self.interactor.dataSource.data.count > 0 {
            cell.hideEmptyCommentLabel()

        } else {
            cell.showEmptyCommentLabel()
        }
		
		
		return cell
	}
}

// MARK: - Private Zone
private extension CommentController {
	
	func showOrHide(){
			DispatchQueue.main.asyncAfter(deadline: .now()) {
				self.mainView.showView()
			}
	}
	
	func displayMention(_ viewModel: Profile) {
		
		guard let id = viewModel.id, let type = viewModel.accountType else {
			return
		}
		
		self.router.routeTo(.showProfile(id: id, type: type))
	}
	
	private func handleReport(_ id: String, _ accountId: String, _ imageUrl: String) {
		if accountId == getIdUser() {
			present(deleteSheet(id, accountId, imageUrl), animated: true, completion: nil)
			return
		}
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.overrideUserInterfaceStyle = .light
        actionSheet.addAction(UIAlertAction(title: .get(.report), style: .default , handler:{ _ in
//            self.presenter.deleteFeedById(id: id)
            
            actionSheet.dismiss(animated: true, completion: {
                self.handleReportWithoutPopUp(id, accountId, imageUrl)
            })
        }))
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        present(actionSheet, animated: true, completion: nil)
//		let reportMenu = ReportMenuController()
//		let rows = 1
//		reportMenu.source(id: id, accountId: accountId, imageUrl: imageUrl, rows: rows)
//		ContextMenu.shared.show(
//			sourceViewController: self,
//			viewController: reportMenu,
//			options: ContextMenu.Options(menuStyle: .minimal, hapticsStyle: .light)
//		)
	}
	
	func deleteSheet(_ id: String, _ accountId: String, _ imageUrl: String) -> UIAlertController {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.overrideUserInterfaceStyle = .light
		actionSheet.addAction(UIAlertAction(title: .get(.deletePost), style: .default , handler:{ _ in
			self.presenter.deleteFeedById(id: id)
				actionSheet.dismiss(animated: true, completion: nil)
		}))
		actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
			actionSheet.dismiss(animated: true, completion: nil)
		}))
		return actionSheet
	}
	
	
	func deleteCommentSheet(_ id: String, _ accountId: String, _ imageUrl: String) -> UIAlertController {
		let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		actionSheet.addAction(UIAlertAction(title: .get(.deletePost), style: .default , handler:{ _ in
			self.deleteCommentID = id
			self.presenter.deleteComment(id : id, feedID: self.interactor.dataSource.postId ?? "")
				actionSheet.dismiss(animated: true, completion: nil)
		}))
		actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
			actionSheet.dismiss(animated: true, completion: nil)
		}))
		return actionSheet
	}
	
	
	private func handleReportWithoutPopUp(_ id: String, _ accountId: String, _ imageUrl: String) {
		if accountId == getIdUser() {
			present(deleteCommentSheet(id, accountId, imageUrl), animated: true, completion: nil)
			return
		}
		ReportNetworkModel().checkIsReportExist(.reportsExist(id: id)) { result in
			switch result {
				case .success(let isExist):
					DispatchQueue.main.async {
					if !(isExist.data ?? false) {
						let reportController = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, networkModel: ReportNetworkModel()))
                        self.navigationController?.pushViewController(reportController, animated: true)
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
	}
	
	func displayHeaderComment(_ viewModel: Feed) {
		guard let post = viewModel.post, let username = viewModel.account?.username, let imageURL = viewModel.account?.photo, let date = viewModel.createAt else {
			return
		}
		self.interactor.dataSource.dataHeader = viewModel
		self.interactor.dataSource.headerItems = CommentHeaderCellViewModel(description: post.postDescription ?? "", username: username, imageUrl: imageURL, date: date, feed: self.interactor.dataSource.dataHeader)
		
		UIView.performWithoutAnimation {
			self.mainView.collectionView.reloadData()
			self.mainView.collectionView.setNeedsLayout()
			self.mainView.collectionView.layoutIfNeeded()
		}
		
		
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.fetchComment(id: id, isPagination: false))
	}
	
	func displayPaginationComment(_ viewModel: [Comment]) {
		self.commentText = ""
		DispatchQueue.global(qos: .background).async {
			self.interactor.dataSource.data.append(contentsOf: viewModel)
		}

		self.mainView.commentTextField.placeholder = String.get(.placeholderComment)
		let offsetBeforeReload = mainView.collectionView.contentOffset
		UIView.performWithoutAnimation {
			self.mainView.collectionView.reloadData()
		}
		mainView.collectionView.performBatchUpdates({
			
		}, completion: { _ in
			self.mainView.collectionView.setContentOffset(offsetBeforeReload, animated: false)
		})
	}
	
	func displayComment(_ viewModel: [Comment]) {
		
		
		_loadingState.accept(false)
		self.interactor.dataSource.data.removeAll()
		self.commentText = ""
		self.mainView.commentTextField.placeholder = String.get(.placeholderComment)
		self.interactor.setPage(page: 0)
		self.interactor.dataSource.data = viewModel
		mainView.collectionView.refreshControl?.endRefreshing()
		let offsetBeforeReload = mainView.collectionView.contentOffset
		
			mainView.collectionView.reloadSections(NSIndexSet(index: 0) as IndexSet)
		
		mainView.collectionView.performBatchUpdates({
			
		}, completion: { _ in
			self.mainView.collectionView.setContentOffset(offsetBeforeReload, animated: false)
		})
		
		showOrHide()
	}
	
	func changeLike(_ viewModel: DefaultResponse) {
		
		guard let index = interactor.dataSource.index else {
			return
		}
		let indexPath = IndexPath(item: index, section: 0)
		let cell = self.mainView.collectionView.cellForItem(at: indexPath) as! CommentCell
		
		if interactor.dataSource.statusLike == "like" {
			let countLike = (self.interactor.dataSource.data[index].like ?? 0) + 1
			self.interactor.dataSource.data[index].isLike = true
			self.interactor.dataSource.data[index].like = countLike
			cell.item?.isLike = true
			cell.totalLikeLabel.text = "\(countLike)"
		} else if (interactor.dataSource.statusLike == "unlike") {
			let countLike = (self.interactor.dataSource.data[index].like ?? 1) - 1
			self.interactor.dataSource.data[index].isLike = false
			self.interactor.dataSource.data[index].like = countLike
			cell.item?.isLike = false
			cell.totalLikeLabel.text = "\(countLike)"
		}
	}
	
	func addComment(_ viewModel: DefaultResponse) {
		self.delegate?.calculate(comment: 1)
		
//			_loadingState.accept(false)
//		refresh()
//		loadinHubDismiss()
		
//		self.mainView.collectionView.reloadData()
		
		let id = interactor.dataSource.id ?? ""
		interactor.doRequest(.fetchComment(id: id, isPagination: false))
		
		
		if fromNewsList {
			let comment = self.interactor.dataSource.dataHeader.comments ?? 0 + 1
			
			let dataDict : [String:Any] = ["index" : self.newsListIndex!, "comments": comment]
			NotificationCenter.default.post(name: newsCellUpdateCommentNotifKey, object: nil, userInfo: dataDict)
		}
		
		if fromNewsDetail {
			let comment = self.interactor.dataSource.dataHeader.comments ?? 0 + 1
			
			let dataDict : [String:Any] = ["index" : self.newsListIndex!, "comments": comment]
			NotificationCenter.default.post(name: newsDetailUpdateCommentNotifKey, object: nil, userInfo: dataDict)
		}
	}
	
	func loadinHubShow() {
		if self.alertController == nil {
			alertController = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
			let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
			loadingIndicator.hidesWhenStopped = true
			loadingIndicator.style = .medium
			loadingIndicator.startAnimating();
			alertController?.view.addSubview(loadingIndicator)
		}
		present(alertController!, animated: true, completion: nil)
	}
	
	func loadinHubDismiss() {
		if self.presentedViewController is UIAlertController {
			dismiss(animated: false, completion: dismissKeyboard)
		}
	}
}


