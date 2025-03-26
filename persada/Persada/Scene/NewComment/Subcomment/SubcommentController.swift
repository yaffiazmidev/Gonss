//
//  SubcommentController.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import ContextMenu
import Combine
import CombineCocoa

protocol SubcommentDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: SubcommentModel.ViewModel)
}

class SubcommentController: UIViewController, SubcommentDisplayLogic, AlertDisplayer {
    
    let titleLabel: ActiveLabel = {
        let label: ActiveLabel = ActiveLabel()
        label.font = .Roboto(.regular, size: 12)
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.mentionColor = .secondary
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.textColor = .black
        return label
    }()
    
	private(set) var cancelable = Set<AnyCancellable>()
	private let mainView: SubcommentView
    var alertController: UIAlertController? = nil
	private var interactor: SubcommentInteractable!
	private var router: SubcommentRouting!
	private var subscriptions: Set<AnyCancellable> = Set<AnyCancellable>()
	weak var delegate: CommentControllerDelegate?
    @Published var loadingState = false

    var addComment : (Int) -> () = { _ in }
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	@Published var commentText: String? = ""
	private var fromNotif : Bool = false
	
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
	
	@objc func onClickDelete() {
		self.interactor.doRequest(.deleteComment)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	
		if interactor.dataSource.headerComment?.username == getUsername() {
			let btnRightMenu: UIButton = UIButton(title: .get(.deletePost), titleColor: .systemRed)
			btnRightMenu.titleLabel?.font = UIFont.Roboto(.bold, size: 14)
			btnRightMenu.addTarget(self, action: #selector(onClickDelete), for: .touchUpInside)
			let rightButton = UIBarButtonItem(customView: btnRightMenu)
			self.navigationItem.rightBarButtonItem = rightButton
		}
		tabBarController?.tabBar.isHidden = true
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.setNavigationBarHidden(false, animated: false)

        let backButton = UIBarButtonItem(image: UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleBack))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
	}
    
    @objc func handleBack() {
        self.navigationController?.popViewController(animated: true)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		tabBarController?.tabBar.isHidden = false
		navigationController?.navigationBar.backgroundColor = nil
	}

	required init(mainView: SubcommentView, dataSource: SubcommentModel.DataSource, fromNotif: Bool? = false) {
		self.mainView = mainView

		super.init(nibName: nil, bundle: nil)
		self.fromNotif = fromNotif ?? false
		interactor = SubcommentInteractor(viewController: self, dataSource: dataSource)
		router = SubcommentRouter(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()
        $loadingState
            .sink { [weak self] isLoading in
            isLoading
                ? self?.loadingHubShow()
                : self?.loadingHubDismiss()
        }.store(in: &cancelable)

		NotificationCenter.default.addObserver(self,
																					 selector: #selector(self.keyboardNotification(notification:)),
																					 name: UIResponder.keyboardWillChangeFrameNotification,
																					 object: nil)

		let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		self.mainView.collectionView.addGestureRecognizer(tap)

		self.mainView.commentTextField.nameTextField.textPublisher
			.receive(on: DispatchQueue.main)
			.assign(to: \.commentText, on: self)
			.store(in: &subscriptions)

		validateButton
			.receive(on: RunLoop.main)
			.assign(to: \.isEmpty, on: self.mainView.submitButton)
			.store(in: &subscriptions)

		self.navigationController?.disableHideKeyboardTappedAround()
		refresh()

	}
	
	override func loadView() {
		view = mainView
		mainView.delegate = self
		mainView.collectionView.delegate = self
		mainView.collectionView.dataSource = self
		mainView.headerItems = interactor.dataSource.headerComment
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}

	// MARK: - SubcommentDisplayLogic
	func displayViewModel(_ viewModel: SubcommentModel.ViewModel) {
		DispatchQueue.main.async {
			switch viewModel {

			case .subcomment(let viewModel):
				self.displaySubcomment(viewModel)
			case .like(let viewModel):
				self.changeLike(viewModel)
			case .addSubcomment(let viewModel):
				self.addSubcomment(viewModel)
			case .paginationSubcomment(let viewModel):
				self.displayPaginationSubcomment(viewModel)
				case .deleteComment(let response):
					self.displayResponseDeleteComment(response: response)
				case .deleteSubComment(let res):
					self.displayDeleteSubcomment(res)
				case .errorMessage(let error):
					self.displayError(error: error)
			case .headerData(viewModel: let viewModel):
				self.setHeader(subcommentData: viewModel)
			}
		}
	}
}


// MARK: - SubcommentViewDelegate
extension SubcommentController: SubcommentViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	func whenSubmitClicked() {
		if mainView.commentTextField.nameTextField.text?.isEmpty ?? false {
			let title = "Warning"
			let action = UIAlertAction(title: "OK", style: .default)
			self.displayAlert(with: title , message: "Empty Message", actions: [action])
		} else {
            loadingState = true
			let commentId = interactor.dataSource.id ?? ""
			let postId = interactor.dataSource.postId ?? ""
			let text = mainView.commentTextField.nameTextField.text ?? ""
			self.delegate?.add(subcomment: 1)
			interactor.doRequest(.addSubcomment(id: postId, commentId: commentId, value: text))
			dismissKeyboard()
		}
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
	
	func refresh() {
		interactor.doRequest(.fetchSubcomment(id: interactor.dataSource.id ?? "", page: 0, isPagination: false))
	}
	
	func pagination(total: Int) {
		if let page = interactor.dataSource.page, (total/10) >= page {
			interactor.setPage(page: page + 1)
//			interactor.doRequest(.fetchSubcomment(id: interactor.dataSource.id ?? "", page: page, isPagination: false))
		}
	}

	func dismiss () {
		router.routeTo(.dismissSubcomment)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		self.interactor.dataSource.data.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: SubCommentCell.self, indexPath: indexPath)
		let row = indexPath.row
		let items = self.interactor.dataSource.data

		
		cell.item = items[row]
		cell.deleteButton.isHidden = getUsername() != items[row].account?.username
		
		cell.likeHandler = { (id, status) in
			let postId = self.interactor.dataSource.postId ?? ""
			
			cell.configureStatusLike(status: status == "like")
			self.interactor.dataSource.index = row
			self.interactor.doRequest(.like(postId: postId, id: id, status: status, index: indexPath.row))
		}

		cell.deleteHandler = {  id in
			self.handleDelete(subCommentId: id)
		}

		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let measurementLabel = UILabel()
		measurementLabel.text = self.interactor.dataSource.headerComment?.description
		measurementLabel.numberOfLines = 0
		measurementLabel.lineBreakMode = .byWordWrapping
		measurementLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let height = measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
		
		return CGSize(width: view.frame.width, height: height + 100)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		let measurementLabel = UILabel()
		measurementLabel.text = self.interactor.dataSource.headerComment?.description
		measurementLabel.numberOfLines = 0
		measurementLabel.lineBreakMode = .byWordWrapping
		measurementLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let height = measurementLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
		
		return CGSize(width: view.frame.width, height: height + 120)
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let cell = collectionView.dequeueReusableCustomHeaderView(with: SubcommentHeaderView.self, indexPath: indexPath)
		
		cell.subcomment = self.interactor.dataSource.headerComment
		
		return cell
	}
}


// MARK: - Private Zone
private extension SubcommentController {
	
	private func handleReport(_ id: String, _ accountId: String) {
		let reportMenu = ReportMenuController()
		let rows = 1
		reportMenu.source(id: id, accountId: accountId, imageUrl: "", rows: rows)
		ContextMenu.shared.show(
			sourceViewController: self,
			viewController: reportMenu,
			options: ContextMenu.Options(menuStyle: .default, hapticsStyle: .medium)
		)
	}

	private func handleDelete(subCommentId: String) {
		let cancelAction = UIAlertAction(title: "Batal", style: .cancel, handler: { _ in

		})
		let actions = [UIAlertAction(title: "Ya", style: .default, handler: { _ in
			self.interactor.doRequest(.deleteSubComment(subCommentId: subCommentId))
		}), cancelAction]

		self.displayAlert(with: "Hapus Komentar", message: "Yakin ingin menghapus komentar ini?", actions: actions)
		cancelAction.setValue(UIColor.warning, forKey: "titleTextColor")
	}
	
	private func resetUI(isDelete: Bool = false) {
		mainView.items?.removeAll()
		mainView.commentTextField.nameTextField.text = ""
		if isDelete && interactor.dataSource.data.count == 1 {
			interactor.dataSource.data.removeAll()
			self.mainView.collectionView.reloadData()
            self.addComment(0)
		}else {
			interactor.doRequest(.fetchSubcomment(id: interactor.dataSource.id ?? "", page: 0, isPagination: false))
		}
	}
	
	func displayPaginationSubcomment(_ viewModel: [Subcomment]) {
		self.commentText = ""
		self.mainView.commentTextField.placeholder = String.get(.placeholderComment)
        self.mainView.commentTextField.nameTextField.centerVerticalText()
		DispatchQueue.global(qos: .background).async {
			self.interactor.dataSource.data.append(contentsOf: viewModel)
		}
		mainView.collectionView.reloadData()
	}

	func displayDeleteSubcomment(_ viewModel: ResultData<DefaultResponse>) {
		switch viewModel {
			case .failure(let err): showToast(message: err?.localizedDescription ?? "Error")
			case .success(_):
				self.delegate?.add(subcomment: -1)
				resetUI(isDelete: true)

		}
	}

	func displaySubcomment(_ viewModel: [Subcomment]) {
		self.interactor.dataSource.data.removeAll()
		self.commentText = ""
		self.mainView.commentTextField.placeholder = String.get(.placeholderComment)
        self.mainView.commentTextField.nameTextField.centerVerticalText()
		self.interactor.dataSource.data = viewModel
        
        self.addComment(viewModel.count)
		mainView.collectionView.refreshControl?.endRefreshing()
		mainView.collectionView.reloadData()
	}

	func displayResponseDeleteComment(response: DefaultResponse) {
		self.delegate?.refreshComment()
		self.navigationController?.popViewController(animated: true)

	}

	func displayError(error: ErrorMessage?) {
		DispatchQueue.main.async {
			self.displayAlert(with: "Error", message: error?.localizedDescription ?? "Unknown Error")
		}
	}
	
	func setHeader(subcommentData: SubcommentResult){
		if fromNotif {
			let desc = subcommentData.data?.value ?? ""
			let username = subcommentData.data?.account?.username ?? ""
			
			var url = "\(subcommentData.data?.account?.photo ?? "")"
			
			let date = subcommentData.data?.createAt ?? 0
			let comment = CommentHeaderCellViewModel(description: desc, username: username, imageUrl: url, date: date, feed: nil)
			self.interactor.dataSource.headerComment = comment
//			mainView.headerItems = comment
		}
	}

	func changeLike(_ viewModel: DefaultResponse) {
		
		guard let index = interactor.dataSource.index else {
			return
		}
		let indexPath = IndexPath(item: index, section: 0)
		
		if interactor.dataSource.statusLike == "like" {

			mainView.collectionView.performBatchUpdates({
				self.interactor.dataSource.data[index].isLike = true
				self.mainView.collectionView.reloadItems(at: [indexPath])
				if self.interactor.dataSource.data[index].isLike! {
					self.interactor.dataSource.data[index].like! += 1
				}
				self.mainView.collectionView.superview?.layoutIfNeeded()
			}, completion: nil)
			
		} else if (interactor.dataSource.statusLike == "unlike") {
			
			mainView.collectionView.performBatchUpdates({
				self.interactor.dataSource.data[index].isLike = false
				self.mainView.collectionView.reloadItems(at: [indexPath])
				if ( self.interactor.dataSource.data[index].isLike == false && self.interactor.dataSource.data[index].like! > 0 ) {
					self.interactor.dataSource.data[index].like! -= 1
				}
				self.mainView.collectionView.superview?.layoutIfNeeded()
			}, completion: nil)
		}
	}

	func addSubcomment(_ viewModel: DefaultResponse) {
		resetUI()
	}
    
    func loadingHubShow() {
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
    
    func loadingHubDismiss() {
        if self.presentedViewController is UIAlertController {
            dismiss(animated: false, completion: dismissKeyboard)
        }
    }

}
