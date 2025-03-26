//
//  CommentHalftViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 03/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared

protocol ICommentHalftController: AnyObject {
    func displayComments(_ comments: [CommentEntity])
    func displayCommentsNextPage(_ comments: [CommentEntity])
    func displayNewComment(_ comment: CommentEntity)
    func displaySuccessDeleteComment(id: String)
    func displaySuccessDeleteSubcomment(commentId: String, id: String)
    func displayProfile(id: String, type: String)
    func displayNotFoundProfile()
    func displayFollowings(items: [RemoteFollowingContent])
}

class CommentHalftController: CustomHalfViewController {
    
    var interactor: ICommentHalftInteractor!
    var router: ICommentHalftRouter!
    var mainView: CommentHalftView!
    
    var comments: [CommentEntity] = []
    var indexPath: IndexPath = IndexPath()
    var isReply: Bool = false
    var replyId: String = ""
    
    var commentCountCallback: ((Int) -> ())?
    var handleClickUser: ((String, String) -> ())?
    var handleEmptyProfile: (() -> ())?
    var handleClickHashtag: ((String) -> ())?
    var handleStartPaidDM: (() -> Void)?
    var shouldResumeFeed: (() -> Void)?
    
    private var timestampStorage: TimestampStorage = TimestampStorage()
    let postAccountId: String
    let postAccountIsVerified: Bool
    let identifier: String
    let chatPrice: Int
    var followings: [RemoteFollowingContent] = []
    
    let MAX_CONTANER_HEIGHT = UIScreen.main.bounds.height * 0.6
    
    private let stackView = UIStackView()
    
    init(postId: String, postAccountId: String, postAccountIsVerified: Bool, identifier: String = "", chatPrice: Int = 1) {
        self.postAccountId = postAccountId
        self.postAccountIsVerified = postAccountIsVerified
        self.identifier = identifier
        self.chatPrice = chatPrice
        super.init(nibName: nil, bundle: nil)
        CommentHalftRouter.configure(self)
        interactor.postId = postId
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navigationController?.isBeingDismissed == true {
            shouldResumeFeed?()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewHeight = MAX_CONTANER_HEIGHT
        
        setupTableView()
        handleOnTap()
        
        let onTapStartPaidViewGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapStartPaidView))
        mainView.startPaidView.isUserInteractionEnabled = true
        mainView.startPaidView.addGestureRecognizer(onTapStartPaidViewGesture)
        
        self.mainView.totalCoin.text = "\(self.chatPrice)"
        print("azmiiii", identifier)
        switch identifier {
//        case "PROFILE_OTHER", "FEED", "CHANNEL_CONTENTS", "SEARCH", "EXPLORE":
//            mainView.paidMessageContainerView.isHidden = postAccountId == getIdUser() ? true : postAccountIsVerified ? false : true
//        case _ where identifier.contains("CLEEPS_"):
//            mainView.paidMessageContainerView.isHidden = postAccountId == getIdUser() ? true : postAccountIsVerified ? false : true
//        case _ where identifier.contains("HASHTAG_"):
//            mainView.paidMessageContainerView.isHidden = postAccountId == getIdUser() ? true : postAccountIsVerified ? false : true
        default:
            mainView.paidMessageContainerView.isHidden = true
        }
        
        interactor.fetchComments()
        interactor.requestFollowing()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.addSubview(mainView.closeIcon)
        mainView.closeIcon.anchor(
            top: containerView.topAnchor,
            right: containerView.rightAnchor,
            paddingTop: 4,
            paddingRight: 1,
            width: 50,
            height: 24
        )
        
        containerView.addSubview(mainView.emptyCommentLabel)
        mainView.emptyCommentLabel.centerXTo(containerView.centerXAnchor)
        mainView.emptyCommentLabel.centerYTo(containerView.centerYAnchor)
        
        containerView.addSubview(mainView.navigationLine)
        mainView.navigationLine.anchor(
            top: mainView.closeIcon.bottomAnchor,
            left: containerView.leftAnchor,
            right: containerView.rightAnchor,
            paddingTop: 4,
            paddingLeft: 0,
            paddingRight: 0,
            height: 1
        )
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        
        NSLayoutConstraint(
            item: stackView,
            attribute: .top,
            relatedBy: .equal,
            toItem: mainView.navigationLine,
            attribute: .bottom,
            multiplier: 1,
            constant: 8
        ).isActive = true
        
        stackView.anchor(
            left: containerView.leftAnchor,
            bottom: UIDevice.safeAreaBottomHeight >= 34 ? containerView.safeAreaLayoutGuide.bottomAnchor : containerView.bottomAnchor,
            right: containerView.rightAnchor,
            paddingLeft: 16,
            paddingBottom: UIDevice.safeAreaBottomHeight >= 34 ? 0 : 16,
            paddingRight: 16
        )
        
        stackView.addArrangedSubview(mainView.paidMessageContainerView)
        stackView.addArrangedSubview(mainView.contentStackView)
        
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.anchor(height: 8)
        
        stackView.addArrangedSubview(spacer)
        stackView.addArrangedSubview(mainView.commentInputView)
        
        mainView.commentInputView.translatesAutoresizingMaskIntoConstraints = false
        mainView.commentInputViewHeightConstraint = mainView.commentInputView.heightAnchor.constraint(equalToConstant: 44)
        
        mainView.paidMessageContainerView.translatesAutoresizingMaskIntoConstraints = false
        mainView.paidMessageContainerView.anchor(height: 40)
        
        containerView.addSubview(mainView.loadingActivityIndicator)
        mainView.loadingActivityIndicator.centerXTo(containerView.centerXAnchor)
        mainView.loadingActivityIndicator.centerYTo(containerView.centerYAnchor)
        
        containerView.addSubview(mainView.commentCountLabel)
        mainView.commentCountLabel.anchor(top: containerView.topAnchor, paddingTop: 9)
        mainView.commentCountLabel.centerXTo(containerView.centerXAnchor)
        
//        mainView.commentTextView.addSubview(mainView.commentTextViewPlaceholder)
//        mainView.commentTextViewPlaceholder.anchor(
//            top: mainView.commentTextView.topAnchor,
//            left: mainView.commentTextView.leftAnchor,
//            right: mainView.commentTextView.rightAnchor,
//            paddingTop: 6
//        )
        
//        mainView.commentTextViewHeightConstraint = mainView.comme.heightAnchor.constraint(equalToConstant: 40)
//        mainView.commentTextViewHeightConstraint?.isActive = true
        mainView.sendIcon.anchor(width: 33, height: 33)
    }
    
    private func setupTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.rowHeight = UITableView.automaticDimension
        mainView.tableView.registerNib(CommentTableViewCell.self)
        mainView.tableView.registerNib(CommentReplyTableViewCell.self)
    }
    
    private func handleOnTap() {
        mainView.closeIcon.onTap { [weak self] in
            guard let self = self else { return }
            self.animateDismissView()
        }
        
        mainView.commentInputView.sendIconContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.handleSendComment(with: self.mainView.commentInputView.textView.text)
        }
        
        mainView.commentInputView.textView.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToCustomCommentInput(attributedText: self.mainView.commentInputView.textView.attributedText, followings: self.followings, isAutoMention: false)
        }
        
        mainView.commentInputView.mentionContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.router.navigateToCustomCommentInput(attributedText: self.mainView.commentInputView.textView.attributedText, followings: self.followings, isAutoMention: true)
        }
    }
    
    @objc private func handleOnTapStartPaidView() {
        
        struct Root: Codable {
            let code: String?
            let message: String?
        }
        
        let channelURL = [getIdUser(), postAccountId].sorted().joined(separator: "_")
        let endpoint: Endpoint<Root?> = Endpoint(
            path: "chat/register-account",
            method: .post,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            bodyParamaters: [
                "externalChannelId": channelURL,
                "payerId": getIdUser(),
                "recipientId": postAccountId
            ]
        )
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                print(error.message)
                DispatchQueue.main.async { Toast.share.show(message: "Failed to start message, please try again..") }
            case .success(_):
                self.handleStartPaidDM?()
            }
        }
    }
    
    private func handleSendComment(with value: String?) {
        guard let value = value, !value.isEmpty else { return }
        guard mainView.commentInputView.textView.attributedText.string.count <= 255 else {
            DispatchQueue.main.async { Toast.share.show(message: "Telah mencapai batas maksimal karakter", backgroundColor: .contentGrey) }
            return
        }
        mainView.sendIcon.image = UIImage(named: .get(.iconFeatherSendGray))
        mainView.defaultTextView()
        isReply ? interactor.replyComment(commentId: replyId, with: value) : interactor.addComment(with: value)
        replyId = ""
        isReply = false
    }
    
    private func handleReplay(id: String, username: String) {
        let mentionAttributedText = NSAttributedString(string: username, attributes: [.foregroundColor: UIColor(hexString: "1890FF"), .font: UIFont.Roboto(size: 12)])
        
        replyId = id
        isReply = true
        router.navigateToCustomCommentInput(attributedText: mentionAttributedText, followings: followings, isAutoMention: false)
    }
}

extension CommentHalftController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { comments.count }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments[section].isOpened ? comments[section].replys.count + 1 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(CommentTableViewCell.self, for: indexPath)
            let comment = comments[indexPath.section]
            cell.delegate = self
            cell.setupView(comment: comment, indexPath: indexPath)
            
            cell.mentionHandler = { [weak self] mention in
                guard let self = self else { return }
                self.interactor.profile(with: mention)
            }
            
            cell.hashtagHandler = { [weak self] hashtag in
                guard let self = self else { return }
                self.navigateToHashtag(hashtag: hashtag)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(CommentReplyTableViewCell.self, for: indexPath)
            let comment = comments[indexPath.section]
            let reply = comment.replys[indexPath.row - 1]

            cell.delegate = self
            cell.setupView(subcomment: reply, commentId: comment.id)
            
            cell.mentionHandler = { [weak self] mention in
                guard let self = self else { return }
                self.interactor.profile(with: mention)
            }
            
            cell.hashtagHandler = { [weak self] hashtag in
                guard let self = self else { return }
                self.navigateToHashtag(hashtag: hashtag)
            }
            return cell
        }
    }
}

extension CommentHalftController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == comments.count - 1 && interactor.page < interactor.totalPage {
            interactor.page += 1
            interactor.fetchComments()
        }
    }
}

extension CommentHalftController: CommentTableViewCellDelegate {
    func didLikeComment(id: String) {
        guard let commentIndex = comments.firstIndex(where: { $0.id == id }) else { return }
        let comment = comments[commentIndex]
        interactor.likeComment(id: id, status: comment.isLike ? "unlike" : "like")
        comments[commentIndex].likes = comment.isLike ? comment.likes - 1 : comment.likes + 1
        comments[commentIndex].isLike = !comment.isLike
        mainView.tableView.reloadSections([commentIndex], with: .none)
    }
    
    func didReportComment(id: String, accountId: String) {
        router.navigateToReport(type: .COMMENT, id: id, accountId: accountId)
    }
    
    func didDeleteComment(id: String) {
        router.showDeleteAlert { [weak self] in
            guard let self = self else { return }
            self.interactor.deleteComment(id: id)
        }
    }
    
    func didReplayComment(id: String, username: String) {
        handleReplay(id: id, username: username)
    }
    
    func didTapSeeMoreReply(indexPath: IndexPath) {
        comments[indexPath.section].isOpened = !comments[indexPath.section].isOpened
        mainView.tableView.reloadSections([indexPath.section], with: .none)
    }
    
    func navigateToProfile(id: String, type: String) {
        guard id != getIdUser() else { return }
        
        dismiss(animated: true) {
            self.handleClickUser?(id, type)
        }
    }
    
    func navigateToHashtag(hashtag: String) {
        dismiss(animated: true) {
            self.handleClickHashtag?(hashtag)
        }
    }
}

extension CommentHalftController: CommentReplyTableViewCellDelegate {
    func didLikeSubcomment(id: String, commentId: String, isLike: Bool) {
        guard let commentIndex = comments.firstIndex(where: { $0.id == commentId }) else { return }
        guard let subcommentIndex = comments[commentIndex].replys.firstIndex(where: { $0.id == id }) else { return }
        let reply = comments[commentIndex].replys[subcommentIndex]
        
        comments[commentIndex].replys[subcommentIndex].likes = reply.isLike ? reply.likes - 1 : reply.likes + 1
        comments[commentIndex].replys[subcommentIndex].isLike = !reply.isLike
        mainView.tableView.reloadRows(at: [IndexPath(item: subcommentIndex + 1, section: commentIndex)], with: .none)
        interactor.likeSubcomment(id: id, status: isLike ? "unlike" : "like")
    }
    
    func didpReplaySubcomment(commentId: String, username: String) {
        handleReplay(id: commentId, username: username)
    }
    
    func didDeleteSubcomment(commentId: String, subcommentId: String) {
        router.showDeleteAlert { [weak self] in
            guard let self = self else { return }
            self.interactor.deleteSubcomment(commentId: commentId, id: subcommentId)
        }
    }
    
    func didReportSubcomment(subcommentId: String, accountId: String) {
        router.navigateToReport(type: .COMMENT_SUB, id: subcommentId, accountId: accountId)
    }
    
    func navigateToProfileSubcomment(id: String, type: String) {
        guard id != getIdUser() else { return }
        
        dismiss(animated: true) {
            self.handleClickUser?(id, type)
        }
    }
}

extension CommentHalftController: ICommentHalftController {
    func displayComments(_ comments: [CommentEntity]) {
        self.comments = comments
        mainView.tableView.reloadData()
        mainView.tableView.alpha = self.comments.isEmpty ? 0 : 1
        mainView.loadingActivityIndicator.stopAnimating()
        mainView.emptyCommentLabel.isHidden = !self.comments.isEmpty
        updateCommentCount()
        //animateContainerHeight(comments.count > 2 ? maximumContainerHeight : viewHeight)
        animateContainerHeight(comments.count > 2 ? MAX_CONTANER_HEIGHT : viewHeight)
        
    }
    
    func displayCommentsNextPage(_ comments: [CommentEntity]) {
        self.comments.append(contentsOf: comments)
        mainView.tableView.reloadData()
        updateCommentCount()
    }
    
    func displayNewComment(_ comment: CommentEntity) {
        comments.insert(comment, at: 0)
        mainView.tableView.alpha = comments.isEmpty ? 0 : 1
        mainView.emptyCommentLabel.isHidden = !comments.isEmpty
        mainView.tableView.insertSections([0], with: .none)
        interactor.totalComments += 1
        updateCommentCount()
    }
    
    func displaySuccessDeleteComment(id: String) {
        guard let index = comments.firstIndex(where: { $0.id == id }) else { return }
        comments.remove(at: index)
        mainView.tableView.beginUpdates()
        mainView.tableView.deleteSections([index], with: .none)
        mainView.tableView.endUpdates()
        interactor.totalComments -= 1
        updateCommentCount()
    }
    
    func displaySuccessDeleteSubcomment(commentId: String, id: String) {
        guard let commentIndex = comments.firstIndex(where: { $0.id == commentId }) else { return }
        guard let subcommentIndex = comments[commentIndex].replys.firstIndex(where: { $0.id == id }) else { return }
        comments[commentIndex].replys.remove(at: subcommentIndex)
        mainView.tableView.beginUpdates()
        mainView.tableView.deleteRows(at: [IndexPath(item: subcommentIndex + 1, section: commentIndex)], with: .none)
        mainView.tableView.reloadSections([commentIndex], with: .none)
        mainView.tableView.endUpdates()
    }
    
    func displayProfile(id: String, type: String) {
        navigateToProfile(id: id, type: type)
    }
    
    func displayNotFoundProfile() {
        dismiss(animated: true) {
            self.handleEmptyProfile?()
        }
    }
    
    func displayFollowings(items: [RemoteFollowingContent]) {
        followings = items
    }
    
    private func updateCommentCount() {
        mainView.commentCountLabel.text = "\(interactor.totalComments) comments"
        commentCountCallback?(interactor.totalComments)
    }
}

extension CommentHalftController: CustomCommentInputViewDelegate {
    func textResult(with text: String?, attributedText: NSAttributedString?, contentSize: CGSize) {
        let isEmptyText = text?.isEmpty == true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mainView.commentInputViewHeightConstraint?.constant = self.mainView.calculateTextViewHeight(with: contentSize) + 16
            self.mainView.commentInputView.textViewHeightConstraint.constant = contentSize.height <= 44 ? 28 : contentSize.height
            self.mainView.commentInputView.layoutIfNeeded()
            self.containerView.layoutIfNeeded()
            self.view.layoutIfNeeded()
            self.mainView.sendIcon.image = UIImage(named: .get(!isEmptyText ? .iconCommentSend : .iconFeatherSendGray))
            self.mainView.commentInputView.placeholderLabel.isHidden = !isEmptyText
            self.mainView.commentInputView.sendIconContainerStackView.isHidden = isEmptyText
            self.mainView.commentInputView.textView.textContainerInset = .init(top: 2, left: 0, bottom: 0, right: 0)
            self.mainView.commentInputView.textView.attributedText = isEmptyText ? nil : attributedText
        }
        
        if isReply {
            isReply = !isEmptyText
            replyId = isEmptyText ? "" : replyId
        }
    }
    
    func didSendComment(with text: String?) {
        handleSendComment(with: text)
    }
}

extension CommentHalftController: ReportFeedDelegate {
    func reported() {
        navigationController?.popViewController(animated: true)
        interactor.page = 0
        interactor.fetchComments()
        router.showReportPopUp()
    }
}
