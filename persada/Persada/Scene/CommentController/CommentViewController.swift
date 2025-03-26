//
//  CommentViewController.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 05/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import IGListKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import KipasKipasShared

class FeedCommentMentionEntity: CreateMention {
    var slug: String = ""
    var fullName: String = ""
    var name: String = ""
    var photoUrl: String = ""
    var range: NSRange = NSMakeRange(0, 0)
    var isFollow: Bool = false
    
    init(follower: Follower) {
        self.fullName = follower.name ?? ""
        self.slug = follower.username?.lowercased() ?? ""
        self.photoUrl = follower.photo ?? ""
        self.name = "@\(follower.username ?? "")"
        self.isFollow = follower.isFollow ?? false
    }
    
    init(fullName: String = "", username: String = "", photoUrl: String = "", isFollow: Bool = false) {
        self.slug = username.lowercased()
        self.fullName = fullName
        self.name = "@\(username)"
        self.photoUrl = photoUrl
        self.isFollow = isFollow
    }
}

class CommentViewController : UIViewController, ListAdapterDataSource, UIGestureRecognizerDelegate, AlertDisplayer {
    
    var data = [ListDiffable]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var commentBoxContainer: UIView!
    
    @IBOutlet weak var commentInputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentInputTextView: UITextView! {
        didSet {
            commentInputTextView.layer.cornerRadius = 8
            commentInputTextView.layer.borderWidth = 1
            commentInputTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet weak var mentionTableView: UITableView!
    @IBOutlet weak var commentInputTextViewPlaceholderLabel: UILabel!
	
	let popupReport = ReportPopupViewController(mainView: ReportPopupView())
    
    let refreshControl = UIRefreshControl()
    
    
    var deleteFeed : () -> () = { }
    var likeChange : (Bool, Int) -> () = { _, _ in }
    var commentChange : (Int) -> () = { _ in }
    
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    let disposeBag = DisposeBag()
    
    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self, workingRangeSize: 0)
    }()
    
    var commentDataSource : CommentDataSource?
    
    var isPresent = false
    
    required init(commentDataSource : CommentDataSource) {
        super.init(nibName: nil, bundle: nil)
        self.commentDataSource = commentDataSource
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
        setupView()
    }
    
    func setupView(){
        self.title = .get(.commenter)
        tabBarController?.tabBar.isHidden = true
        overrideUserInterfaceStyle = .light
        let backButton = UIBarButtonItem(image: UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(back))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.displayShadowToNavBar(status: true)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        commentDataSource?.getHeaderPostComment()
    }
    
    @objc
    func back(){
        if isPresent {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private let mentionAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: UIColor.systemBlue),
        Attribute(name: .font, value: UIFont(name: "Roboto-Bold", size: 12)!),
    ]
    
    private let defaultAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)),
        Attribute(name: .font, value: UIFont(name: "Roboto-Regular", size: 12)!),
    ]
    
    private var listener: MentionListener?
    private var filterString: String = ""
    fileprivate var mentions: [FeedCommentMentionEntity] = []
    
    private var mentionsList: [FeedCommentMentionEntity] {
        guard !mentions.isEmpty, filterString != "" else { return [] }
        let keyword = filterString.lowercased()
        return mentions
            .filter { $0.slug.contains(keyword) }
            .sorted { ($0.slug.hasPrefix(keyword) ? 0 : 1) < ($1.slug.hasPrefix(keyword) ? 0 : 1) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupCollectionView()
        
        //fetch comment listener
        commentDataSource?.postViewModel.bind(onNext: { [weak self] postViewModel in
            guard let post = postViewModel else { return }
            guard let self = self else { return }
            self.data.append(post)
            
            
            self.adapter.reloadData { (bool) in
                self.adapter.performUpdates(animated: true)
            }
        }).disposed(by: disposeBag)
        
        commentDataSource?.isLoading.bind(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.collectionView.isHidden = true
                self?.hud.show(in: view)
                self?.commentBoxContainer.isHidden = false
                self?.commentInputTextView.isUserInteractionEnabled = false
                return
            } else {
                self?.collectionView.isHidden = false
                self?.hud.dismiss()
                self?.refreshControl.endRefreshing()
                self?.commentBoxContainer.isHidden = false
                self?.commentInputTextView.isUserInteractionEnabled = true
            }
        }).disposed(by: disposeBag)
        
        commentDataSource?.isLoadingCommentUpdate.bind(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            DispatchQueue.main.async {
                if isLoading {
                    guard let view = self?.view else { return }
                    self?.hud.show(in: view)
                    self?.commentInputTextView.isUserInteractionEnabled = false
                    return
                } else {
                    self?.hud.dismiss()
                    self?.commentInputTextView.isUserInteractionEnabled = true
                }
            }
        }).disposed(by: disposeBag)
        
        commentDataSource?.commentUpdated.bind(onNext: { [weak self ] postViewModel in
            guard let post = postViewModel else { return }
            guard let self = self else { return }
            post.action.totalComment = post.action.totalComment + 1
            self.data = [post]
            self.commentChange(post.action.totalComment)
            
            let totalCommentNotToScrollToBottom = 1
            self.adapter.reloadData { (bool) in
                self.adapter.performUpdates(animated: true)
                if post.action.totalComment == totalCommentNotToScrollToBottom {
                    self.collectionView.setContentOffset(.zero, animated: true)
                } else {
                    self.collectionView.scrollToBottom()
                }
            }
        }).disposed(by: disposeBag)
        
        
        sendCommentButton.onTap {
            self.view.endEditing(true)
            self.sendCommentButton.isEnabled = false
            guard let comment = self.commentInputTextView.text else { return }
            guard let id = self.commentDataSource?.postViewModel.value?.postID else { return }
            
            self.commentDataSource?.addComment(id: id, value: comment, onSuccess: {
                self.commentDataSource?.updateComment()
                DispatchQueue.main.async {
                    
                    self.sendCommentButton.image(.get(.iconFeatherSendGray))
                    self.commentInputTextView.text = ""
                }
            }, onError: { error in
                let action = UIAlertAction(title: "OK", style: .default) { action in
                     self.sendCommentButton.isEnabled = true
                }
                self.displayAlert(with: "Error", message: error,actions: [action])
            })
        }
        
        commentDataSource?.filterFollower.bind(onNext: { [weak self] data in
            self?.mentions = data
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentInputTextView.inputAccessoryView = nil
        
        let maxHeight:CGFloat = 150
        let maxTextHeight:CGFloat = 150
        let minTextHeight:CGFloat = 28
        
        var resizeHeight = mentionTableView.contentSize.height
        var resizeTextHeight = commentInputTextView.contentSize.height
        if resizeHeight > maxHeight { resizeHeight = maxTextHeight }
        if resizeTextHeight > maxTextHeight { resizeTextHeight = maxTextHeight }
        if resizeTextHeight < minTextHeight { resizeTextHeight = minTextHeight }
        
        mentionTableViewHeightConstraint.constant = resizeHeight
        commentInputTextViewHeightConstraint.constant = resizeTextHeight
    }
    
    func setupTableView() {
        mentionTableView.delegate = self
        mentionTableView.dataSource = self
        mentionTableView.rowHeight = UITableView.automaticDimension
        mentionTableView.register(UINib(nibName: "MentionCellTableViewCell", bundle: nil), forCellReuseIdentifier: "MentionCellTableViewCell")
        
        let mentionsListener = MentionListener(mentionsTextView: commentInputTextView,
                                               mentionTextAttributes: { _ in self.mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: true,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString)
        commentInputTextView.delegate = mentionsListener
        listener = mentionsListener
    }
    
    func refreshCommentCount(post : PostViewModel){
        self.data = [post]
        self.commentChange(post.action.totalComment)
        DispatchQueue.main.async {
            self.adapter.reloadData { (bool) in
                self.adapter.performUpdates(animated: true)
                self.collectionView.setContentOffset(.zero, animated: true)
            }
        }
    }
    
    func setupCollectionView(){
        view.addSubview(collectionView)
        adapter.dataSource = self
        adapter.collectionView = self.collectionView
    }
    
    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data
    }
    
    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return CommentSectionController()
    }
    
    lazy var emptyLabel : UILabel = {
        let label = UILabel(text: "", font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        label.isHidden = true
        return label
    }()
    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        self.view.addSubview(emptyLabel)
        emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyLabel.anchor(width: 250, height: 250)
        commentDataSource?.errorMessage.bind(onNext: { [weak self] errorMessage in
            guard let error = errorMessage else { return }
            guard let self = self else { return }
            self.emptyLabel.text = error
            self.commentBoxContainer.isHidden = true
        }).disposed(by: disposeBag)
        return emptyLabel
    }
}


extension CommentViewController: ReportFeedDelegate, PopupReportDelegate {
    func reported() {
        DispatchQueue.main.async {
            let popup = ReportPopupViewController(mainView: ReportPopupView())
			popup.mainView.delegate = self
            popup.modalPresentationStyle = .overFullScreen
            self.present(popup, animated: false, completion: nil)
        }
    }
	
	func closePopUp(id: String, index: Int) {
		self.dismiss(animated: false, completion: nil)
	}
}

extension CommentViewController {
    func hideMentions() {
        filter("")
        handleMaxCommentLenght()
    }
    
    func didHandleMentionOnReturn() -> Bool { return false }
    
    func showMentionsListWithString(mentionsString: String, trigger _: String) {
        handleMaxCommentLenght()
        filter(mentionsString)
    }
    
    func handleMaxCommentLenght() {
        if let text = commentInputTextView.text, text.count > 250 { commentInputTextView.text.removeLast() }
    }
}

extension CommentViewController: UITableViewDelegate {
    
    func filter(_ string: String) {
        var emptyInputTV = ""
        if commentInputTextView.text.isEmpty == true {
            emptyInputTV = String.get(.iconFeatherSendGray)
        } else {
            emptyInputTV = String.get(.iconFeatherSend)
        }
        sendCommentButton.image(emptyInputTV)
        sendCommentButton.isEnabled = !commentInputTextView.text.isEmpty
        commentInputTextViewPlaceholderLabel.isHidden = !commentInputTextView.text.isEmpty
        
        filterString = string
        mentionTableView.reloadData()
        viewDidLayoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.addMention(mentionsList[indexPath.row])
    }
}


extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCellTableViewCell", for: indexPath) as! MentionCellTableViewCell
        let mention = mentionsList[indexPath.row]
        cell.usernameLabel.text = String(mention.name.dropFirst())
        cell.nameLabel.text = mention.fullName
        cell.pictureImageView.loadImage(at: mention.photoUrl)
        return cell
    }
}
