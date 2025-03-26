//
//  TiktokCommentViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 20/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import FittedSheets
import SwiftUI
import RxSwift
import Combine
import RxRelay

protocol CommentSheetDelegate {
    static func openSheet(from parent: UIViewController, comments: Int, idPost: String, onDataChanged: @escaping ((_ count: Int) -> Void))
}

enum CommentState {
    case empty
    case loading
    case hasData
}

class CommentSheetViewController: UIViewController {
    
    @IBOutlet var labelCommentCount: UILabel!
    @IBOutlet var collectionViewComment: UICollectionView!
    @IBOutlet weak var tableViewMention: UITableView!
    @IBOutlet weak var tableViewMentionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewCommentHeightConstraint: NSLayoutConstraint!
    @IBOutlet var labelPlaceHolder: UILabel!
    @IBOutlet var textViewComment: UITextView!{
        didSet {
            textViewComment.layer.cornerRadius = 8
            textViewComment.layer.borderWidth = 1
            textViewComment.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    @IBOutlet var buttonSend: UIButton!
    
    private var comments: [Comment]?
    private var state: CommentState!
    private var idPost: String!
    private var page: Int!
    private var onDataChanged: ((_ count: Int) -> Void)!
    
    private let feedNetwork: FeedNetworkModel = FeedNetworkModel()
    private let profileNetwork: ProfileNetworkModel = ProfileNetworkModel()
    private var filterFollower = BehaviorRelay<[FeedCommentMentionEntity]>(value: [])
    private var subscriptions = [AnyCancellable]()
    
    var closeSheet: (() -> Void)!
    var sheetFullScreen: Bool!
    var onSheetReachTop: (() -> Void)!
    var onKeyboard: ((_ percent: Float) -> Void)!
    var changeMinSizeSheet: ((_ size: SheetSize) -> Void)!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification , object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .handleReportComment , object: nil)
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        let heightScreen = UIScreen.main.bounds.height
        self.onKeyboard(Float(keyboardHeight / heightScreen))
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        self.onKeyboard(0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleReport(notification:)), name: .handleReportComment, object: nil)
        
        collectionViewComment.register(UINib(nibName: CommentPlaceholderViewCell.className, bundle: nil), forCellWithReuseIdentifier: CommentPlaceholderViewCell.idCell)
        collectionViewComment.register(UINib(nibName: CommentSectionViewCell.className, bundle: nil), forCellWithReuseIdentifier: CommentSectionViewCell.idCell)
        setupMentionTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textViewComment.inputAccessoryView = nil
        
        let maxHeight:CGFloat = 150
        let maxTextHeight:CGFloat = 150
        let minTextHeight:CGFloat = 28
        
        var resizeHeight = tableViewMention.contentSize.height
        var resizeTextHeight = textViewComment.contentSize.height
        if resizeHeight > maxHeight { resizeHeight = maxTextHeight }
        if resizeTextHeight > maxTextHeight { resizeTextHeight = maxTextHeight }
        if resizeTextHeight < minTextHeight { resizeTextHeight = minTextHeight }
        
        tableViewMentionHeightConstraint.constant = resizeHeight
        tableViewCommentHeightConstraint.constant = resizeTextHeight
    }
    
    func setupView(comments: Int, idPost: String){
        state = .empty
        self.page = 0
        self.idPost = idPost
        setCommentCount(comments)
        collectionViewComment.delegate = self
        collectionViewComment.dataSource = self
        collectionViewComment.backgroundColor = .white
        collectionViewComment.autoresizesSubviews
        getComments()
    }
    
    private func setCommentCount(_ counts: Int){
        var commentText = "comment"
        if counts > 1{
            commentText.append("s")
        }
        
        labelCommentCount.text = "\(counts) \(commentText)"
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.closeSheet()
    }
    
    @IBAction func onSend(_ sender: Any) {
        buttonSend.isEnabled = false
        sendComment { response in
            print("CommentSheet - onSend - success")
            DispatchQueue.main.async {
                self.textViewComment.text = ""
            }
            self.getComments()
        } onFailure: { error in
            print("CommentSheet - onSend - failure \(error?.statusMessage)")
            self.showAlert(title: "Gagal mengirim comment", message: "\(error?.statusMessage ?? "")")
        }
        buttonSend.isEnabled = true
    }
    
    func setupMentionTableView() {
        tableViewMention.backgroundColor = .white
        tableViewMention.delegate = self
        tableViewMention.dataSource = self
        tableViewMention.rowHeight = UITableView.automaticDimension
        tableViewMention.register(UINib(nibName: "MentionCellTableViewCell", bundle: nil), forCellReuseIdentifier: "MentionCellTableViewCell")
        
        let mentionsListener = MentionListener(mentionsTextView: textViewComment,
                                               mentionTextAttributes: { _ in self.mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: true,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString)
        textViewComment.delegate = mentionsListener
        listener = mentionsListener
    }
    
    func handleTapMention(_ text: String) {
        mention(word: text) { [weak self] userID, userType in
            self?.routeToProfile(userID, userType)
        } onError: { error in
            if error == "Data Not Found" {
                self.navigationController?.pushViewController(EmptyUserProfileViewController(), animated: true)
            } else {
                //                self.showErrorAlert(error: error)
                print("error")
            }
        }
    }
    
    @objc
    func handleReport(notification: NSNotification){
        if let dict = notification.userInfo as NSDictionary? {
            if let result =  dict["result"] as? ResultData<DefaultResponse> {
                switch result {
                case .success(_):
                    print("CommentSheet - onReport : success")
                    if let id = dict["id"] as? String{
                        var idx: Int?
                        for comment in comments! {
                            if comment.id == id {
                                idx = comments!.firstIndex(of: comment)
                                break
                            }
                        }
                        if let idx = idx {
                            self.comments?.remove(at: idx)
                            let indexPath = IndexPath(row: idx, section: 0)
                            modifyCommentAt(indexPath: indexPath) {
                                self.collectionViewComment.deleteItems(at: [indexPath])
                            } onCompleted: {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    let reportPVC = ReportPopupViewController(mainView: ReportPopupView())
                                    
                                    reportPVC.modalPresentationStyle = .overFullScreen
                                    reportPVC.mainView.onBackPressed = {
                                        reportPVC.dismiss(animated: true)
                                    }
                                    
                                    self.present(reportPVC, animated: false, completion: nil)
                                }
                            }
                            
                        }
                    }
                case .failure(let error):
                    print("CommentSheet - onDelete : failure \(error)")
                    self.showAlert(title: "Gagal report comment", message: "\(error?.statusMessage ?? "")")
                }
            }
        }
    }
}

// MARK: - Sheet Delegate
extension CommentSheetViewController: CommentSheetDelegate {
    static func openSheet(from parent: UIViewController, comments: Int, idPost: String, onDataChanged: @escaping ((_ count: Int) -> Void)) {
        let sb = UIStoryboard(name: "CommentSheetViewController", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "commentSheetController")
        
        let opt = SheetOptions(pullBarHeight: 0, useInlineMode: true)
        let svc = SheetViewController(
            controller: vc,
            sizes: [.fixed(300), .percent(0.9)],
            options: opt)
        
        svc.animateIn(to: parent.view, in: parent)
        let view = vc as! CommentSheetViewController
        view.setupView(comments: comments, idPost: idPost)
        view.onDataChanged = onDataChanged
        view.sheetFullScreen = false
        view.collectionViewComment.isScrollEnabled = false
        view.closeSheet = {
            svc.animateOut()
        }
        
        svc.sizeChanged = { sheet, size, height in
            view.sheetFullScreen = (size == .percent(0.9))
            view.collectionViewComment.isScrollEnabled = view.sheetFullScreen
        }
        view.onSheetReachTop = {
            svc.resize(to: .fixed(300))
        }
        view.onKeyboard = { percent in
            if view.view.frame.height > 300 {
                svc.resize(to: .percent(0.9 - percent))
            }
        }
        view.changeMinSizeSheet = { size in
            svc.sizes = [size, .percent(0.9)]
            svc.resize(to: size)
        }
    }
}

//MARK: - CollectionView DataSource & Delegate
extension CommentSheetViewController : UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        labelPlaceHolder.isHidden = !textView.text.isEmpty
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 && sheetFullScreen {
            collectionViewComment.isScrollEnabled = false
            self.onSheetReachTop()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.state != .hasData {
            return CGSize(width:  UIScreen.main.bounds.width, height: 126)
        }
        var height = 0.0
        if let cell = collectionViewComment.dequeueReusableCell(withReuseIdentifier: CommentSectionViewCell.idCell, for: indexPath) as? CommentSectionViewCell{
            cell.contentView.setNeedsLayout()
            cell.contentView.layoutIfNeeded()
            
            let comment = comments?[indexPath.row].value ?? ""
            let labelWidth = UIScreen.main.bounds.width - 92
            let constraintRect = CGSize(width: labelWidth, height: .greatestFiniteMagnitude)
            let boundingBox = comment.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.Roboto(.regular, size: 12.0)], context: nil)
            
            height = ceil(boundingBox.height)
        }
        return CGSize(width: UIScreen.main.bounds.width, height: 77 + height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.state != .hasData {
            return 1
        }
        return comments?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.state != .hasData {
            let cell = collectionViewComment.dequeueReusableCell(withReuseIdentifier: CommentPlaceholderViewCell.idCell, for: indexPath) as! CommentPlaceholderViewCell
            cell.setViewByState(self.state)
            return cell
        }
        
        let cell = collectionViewComment.dequeueReusableCell(withReuseIdentifier: CommentSectionViewCell.idCell, for: indexPath) as! CommentSectionViewCell
        cell.setupView(
            data: comments![indexPath.row],
            isSubComment: false,
            onReply: { item in
                
            },
            onReport: { item in
                let commentRouter = CommentSectionRouter(self)
                commentRouter.presentReportSheet(id: item.id ?? "", accountId: item.account?.id ?? "", imageUrl: item.account?.photo ?? "", reportType: .COMMENT)
            },
            onDelete: { item in
                cell.alpha = 0.5
                self.feedNetwork.deleteComment(.deleteComment(id: item.id ?? "")) { result in
                    switch result {
                    case .success(_):
                        print("CommentSheet - onDelete : success")
                        self.comments?.remove(at: indexPath.row)
                        self.modifyCommentAt(indexPath: indexPath){
                            self.collectionViewComment.deleteItems(at: [indexPath])
                        }
                    case .failure(let error):
                        print("CommentSheet - onDelete : failure \(error)")
                        cell.alpha = 1.0
                        self.showAlert(title: "Gagal menghapus komentar", message: "\(error?.statusMessage ?? "")")
                    }
                }
            },
            onLike: { item, isLiked in
                let status : String!
                if isLiked {
                    status = "like"
                } else {
                    status = "unlike"
                }
                
                self.feedNetwork.requestLike(.commentLike(id: self.idPost, commentId: item.id ?? "", status: status)) { [weak self] result in
                    switch result {
                    case .success(_):
                        print("CommentSheet - onLike : success")
                    case .failure(let error):
                        print("CommentSheet - onLike : failure \(error)")
                        if var comment = self?.comments?[indexPath.row] as? Comment {
                            comment.isLike = !isLiked
                            var count: Int = comment.like ?? 0
                            if isLiked {
                                count -= 1
                            }else{
                                count += 1
                            }
                            
                            self?.modifyCommentAt(indexPath: indexPath) {
                                self?.comments?[indexPath.row] = comment
                            }
                        }
                        self?.showAlert(title: "Gagal like comment", message: "\(error?.statusMessage ?? "")")
                    }
                }
            }
        )
        return cell
    }
}

//MARK: - TableView Mention Delegate
extension CommentSheetViewController: UITableViewDelegate {
    func filter(_ string: String) {
        //        sendCommentButton.image(.get(commentInputTextView.text.isEmpty ? .iconFeatherSendGray : .iconFeatherSend))
        buttonSend.isEnabled = !textViewComment.text.isEmpty
        labelPlaceHolder.isHidden = !textViewComment.text.isEmpty
        searchAccount(string)
        filterString = string
        tableViewMention.reloadData()
        viewDidLayoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.addMention(mentionsList[indexPath.row])
    }
}

//MARK: - TableView Mention DataSource
extension CommentSheetViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCellTableViewCell", for: indexPath) as! MentionCellTableViewCell
        cell.backgroundColor = .white
        cell.nameLabel.textColor = .black
        let mention = mentionsList[indexPath.row]
        cell.nameLabel.text = String(mention.name.dropFirst())
        cell.usernameLabel.text = mention.fullName
        cell.pictureImageView.loadImage(at: mention.photoUrl)
        return cell
    }
}

// MARK: - Helper
extension CommentSheetViewController {
    private func refreshState(_ state: CommentState, label: String? = nil){
        self.state = state
        self.setCommentCount(self.comments?.count ?? 0)
        if state != .hasData {
            self.changeMinSizeSheet(.fixed(300))
            let cell = self.collectionViewComment.visibleCells.first as! CommentPlaceholderViewCell
            cell.setViewByState(self.state)
            if let text = label {
                cell.setLabel(text: text)
            }
        }else{
            self.changeMinSizeSheet(.percent(0.7))
            self.onDataChanged(self.comments?.count ?? 0)
            collectionViewComment.reloadData()
        }
    }
    
    private func modifyCommentAt(indexPath: IndexPath, action: @escaping (() -> Void), onCompleted: (() -> Void)? = nil){
        DispatchQueue.main.async {
            self.collectionViewComment.performBatchUpdates({
                action()
            }, completion: {
                (finished: Bool) in
                self.collectionViewComment.reloadItems(at: self.collectionViewComment.indexPathsForVisibleItems)
                let counts = self.comments?.count ?? 0
                self.setCommentCount(counts)
                if counts == 0 {
                    self.state = .empty
                }
                self.onDataChanged?(counts)
                onCompleted?()
            })
        }
    }
    
    func routeToProfile(_ id: String,_ type: String) {
        let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
        controller.setProfile(id: id, type: type)
        controller.bindNavigationBar("", true)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func hideMentions() {
        filter("")
    }
    
    func didHandleMentionOnReturn() -> Bool { return false }
    
    func showMentionsListWithString(mentionsString: String, trigger _: String) {
        filter(mentionsString)
    }
}

// MARK: - Request Network
extension CommentSheetViewController {
    private func getComments(){
        state = .loading
        feedNetwork.fetchComment(.comments(id: idPost, page: page)).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
                var message: String
                if let error = error as? ErrorMessage {
                    message =  error.statusMessage ?? "Unknown error"
                    return
                }
                message =  error.localizedDescription
                self.refreshState(.empty, label: message)
            case .finished: break
            }
        }) { [weak self] (model: CommentResult) in
            guard let self = self else { return }
            self.comments = model.data?.content
            self.comments?.reverse()
            self.state = .hasData
            if self.comments?.count ?? 0 > 0{
                self.refreshState(.hasData)
            }else {
                self.refreshState(.empty)
            }
        }.store(in: &subscriptions)
    }
    
    private func sendComment(onSuccess: @escaping ((_ response: DefaultResponse) -> Void),  onFailure:@escaping ((_ error: ErrorMessage?) -> Void)){
        feedNetwork.addComment(.addComment(id: idPost, value: textViewComment.text)) { result in
            switch result {
            case .success(let response):
                onSuccess(response)
            case .failure(let err):
                onFailure(err)
            }
        }
    }
    
    func mention(word: String, onSuccess: @escaping (String, String) -> (), onError: @escaping (String) -> ()) {
        print("CommentSheet - mention \(word)")
        profileNetwork.profileUsername(.profileUsername(text: word)).sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                if let error = error as? ErrorMessage {
                    onError(error.statusMessage ?? "unknown error")
                    return
                }
                onError(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: ProfileResult) in
            guard self != nil else { return }
            guard let id = model.data?.id else { return }
            onSuccess(id, model.data?.accountType ?? "social")
        }.store(in: &subscriptions)
    }
    
    func searchAccount(_ text: String) {
        print("CommentSheet - mention \(text)")
        profileNetwork.searchFollowers(.searchFollowing(id: getIdUser(), name: text, page: 0))
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error): print(error.localizedDescription)
                }
            }) { [weak self] (model: FollowerResult) in
                guard let self = self else { return }
                let result = model.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                self.filterFollower.accept(result ?? [])
            }.store(in: &subscriptions)
    }
}

// MARK: - Alert Displayer
extension CommentSheetViewController: AlertDisplayer {
    func showErrorAlert(error: String){
        DispatchQueue.main.async {
            let action = UIAlertAction(title: .get(.ok), style: .default)
            self.displayAlert(with: .get(.error), message: error, actions: [action])
        }
    }
    
    func showAlert(title: String, message: String){
        DispatchQueue.main.async {
            let action = UIAlertAction(title: .get(.ok), style: .default)
            self.displayAlert(with: title, message: message, actions: [action])
        }
    }
}
