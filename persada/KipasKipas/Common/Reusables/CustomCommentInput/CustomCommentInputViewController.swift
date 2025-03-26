//
//  CustomCommentInputViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/08/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import KipasKipasShared

protocol CustomCommentInputViewDelegate: AnyObject {
    func textResult(with text: String?, attributedText: NSAttributedString?, contentSize: CGSize)
    func didSendComment(with text: String?)
}

class CustomCommentInputViewController: UIViewController {
    
    @IBOutlet weak var mentionContainerStackView: UIStackView!
    @IBOutlet weak var buttonSendContainerStackView: UIStackView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mentionTableView: UITableView!
    @IBOutlet weak var commentInputTextView: UITextView!
    @IBOutlet weak var commentInputTextViewPlaceholderLabel: UILabel!
    @IBOutlet weak var commentInputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emoji1ImageView: UIImageView!
    @IBOutlet weak var emoji2ImageView: UIImageView!
    @IBOutlet weak var emoji3ImageView: UIImageView!
    @IBOutlet weak var emoji4ImageView: UIImageView!
    @IBOutlet weak var emoji5ImageView: UIImageView!
    @IBOutlet weak var emoji6ImageView: UIImageView!
    @IBOutlet weak var emoji7ImageView: UIImageView!
    
    weak var delegate: CustomCommentInputViewDelegate?
    private let disposeBag = DisposeBag()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private var listener: MentionListener?
    private var filterString: String = ""
    private var mentions: [FeedCommentMentionEntity] = []
    private var draftAttributeText: NSAttributedString?
    private let followings: [RemoteFollowingContent]
    private let isAutoMention: Bool
    
    
    init(draftAttributeText: NSAttributedString? = nil, followings: [RemoteFollowingContent] = [], isAutoMention: Bool = false) {
        self.followings = followings
        self.isAutoMention = isAutoMention
        super.init(nibName: nil, bundle: nil)
        self.draftAttributeText = draftAttributeText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 24
        commentInputTextView.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userLoggedIn = LoggedUserKeychainStore(key: .loggedInUser).retrieve() {
            userProfileImageView.loadImageWithoutOSS(at: userLoggedIn.photoUrl, placeholder: UIImage(named: "default-profile-image-small-circle"))
        }
        
        setupMentionTableView()
        setDraftText()
        handleOnTap()
        
        if isAutoMention {
            guard commentInputTextView.attributedText.string.count < 255 else { return }
            appendTextToField(with: commentInputTextView.text.isEmpty ? "@" : " @")
            let followings = self.followings.compactMap({ FeedCommentMentionEntity.init(fullName: $0.name ?? "", username: $0.username ?? "", photoUrl: $0.photo ?? "", isFollow: true) })
            mentions = followings
            mentionTableView.reloadData()
            calculateComponentHeight()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commentInputTextView.inputAccessoryView = nil
        calculateComponentHeight()
    }
    
    private func handleOnTap() {
        containerView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: true) {
                self.delegate?.textResult(with: self.commentInputTextView.text, attributedText: self.commentInputTextView.attributedText, contentSize: self.commentInputTextView.contentSize)
            }
        }
        
        emoji1ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "😁")
        }
        
        emoji2ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "😂")
        }
        
        emoji3ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "🥰")
        }
        
        emoji4ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "😳")
        }
        
        emoji5ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "😏")
        }
        
        emoji6ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "😅")
        }
        
        emoji7ImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.appendTextToField(with: "🥹")
        }
        
        mentionContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            guard commentInputTextView.attributedText.string.count < 255 else { return }
            self.appendTextToField(with: commentInputTextView.text.isEmpty ? "@" : " @")
            self.mentions = followings.compactMap({ FeedCommentMentionEntity.init(fullName: $0.name ?? "", username: $0.username ?? "", photoUrl: $0.photo ?? "", isFollow: true) })
            self.calculateComponentHeight()
            self.mentionTableView.reloadData()
        }
        
        buttonSendContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            guard self.commentInputTextView.attributedText.string.count <= 255 else {
                DispatchQueue.main.async { Toast.share.show(message: "Telah mencapai batas maksimal karakter", backgroundColor: .contentGrey) }
                return
            }
            self.dismiss(animated: true) {
                self.delegate?.didSendComment(with: self.commentInputTextView.text)
            }
        }
    }
    
    private func appendTextToField(with value: String, attributedText: NSAttributedString? = nil) {
        if let attributedText = commentInputTextView.attributedText {
            guard attributedText.string.count < 255 else { return }
            let mentionAttributedString = NSAttributedString(string: value, attributes: nil)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.append(mentionAttributedString)
            commentInputTextView.attributedText = mutableAttributedString
        }
    }
    
    private func setDraftText() {
        guard let text = draftAttributeText else { return }
        commentInputTextView.attributedText = text
    }
    
    private func enableSendButton() {
        if commentInputTextView.text.isEmpty {
            buttonSendContainerStackView.isHidden = true
            
        } else {
            guard buttonSendContainerStackView.isHidden else { return }
            buttonSendContainerStackView.alpha = 0
            buttonSendContainerStackView.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIView.animate(withDuration: 0.2) {
                    self.buttonSendContainerStackView.alpha = 1
                }
            }
        }
    }
    
    private func resetMentionTableView() {
        mentions.removeAll()
        mentionTableView.reloadData()
        viewDidLayoutSubviews()
    }
    
    private func calculateComponentHeight() {
        let textHeight = commentInputTextView.contentSize.height
        let calculateTextViewHeight = textHeight >= 100 ? 100 : textHeight >= 28 ? textHeight : 28
        
        let mentionTableHeight = CGFloat(mentions.count * 48)
        let calculateHeight = mentionTableHeight <= 200 ? mentionTableHeight  : 200
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.commentInputTextViewHeightConstraint.constant = calculateTextViewHeight
                self.mentionTableViewHeightConstraint.constant = calculateHeight
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension CustomCommentInputViewController {
    
    private func setupMentionTableView() {
        let mentionAttributes: [AttributeContainerMention] = [
            Attribute(name: .foregroundColor, value: UIColor(hexString: "1890FF")),
            Attribute(name: .font, value: UIFont(name: "Roboto-Regular", size: 16)!),
        ]
        
        let defaultAttributes: [AttributeContainerMention] = [
            Attribute(name: .foregroundColor, value: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)),
            Attribute(name: .font, value: UIFont(name: "Roboto-Regular", size: 16)!),
        ]
        
        mentionTableView.backgroundColor = .white
        mentionTableView.delegate = self
        mentionTableView.dataSource = self
        mentionTableView.rowHeight = UITableView.automaticDimension
        mentionTableView.registerNibCell(MentionCellTableViewCell.self)
        
        let mentionsListener = MentionListener(mentionsTextView: commentInputTextView,
                                               mentionTextAttributes: { _ in mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: true,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString,
                                               maxLang: 255)
        commentInputTextView.delegate = mentionsListener
        commentInputTextView.font = .roboto(.regular, size: 16)
        commentInputTextView.textContainerInset = UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
        mentionsListener.handleMaxLangTriggred = {
            DispatchQueue.main.async {
                Toast.share.show(message: "Telah mencapai batas maksimal karakter", backgroundColor: .contentGrey)
            }
        }
        listener = mentionsListener
    }
    
    private func hideMentions() {
        mentions = []
        filterString = ""
        commentInputTextViewPlaceholderLabel.isHidden = !commentInputTextView.text.isEmpty
        enableSendButton()
        viewDidLayoutSubviews()
    }
    
    private func showMentionsListWithString(mentionsString: String, trigger _: String) {
        enableSendButton()
        commentInputTextViewPlaceholderLabel.isHidden = !commentInputTextView.text.isEmpty
        
        guard !mentionsString.isEmpty else {
            let followings = self.followings.compactMap({ FeedCommentMentionEntity.init(fullName: $0.name ?? "", username: $0.username ?? "", photoUrl: $0.photo ?? "", isFollow: true) })
            mentions = followings
            mentionTableView.reloadData()
            calculateComponentHeight()
            if !mentions.isEmpty { return }
            resetMentionTableView()
            return
        }
        
        searchAccount(text: mentionsString) { [weak self] users in
            guard let self = self else { return }
            self.filterString = mentionsString
            self.mentions = users
            self.mentionTableView.reloadData()
            self.viewDidLayoutSubviews()
        }
    }
    
    private func didHandleMentionOnReturn() -> Bool { return false }
}

extension CustomCommentInputViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = mentions[safe: indexPath.row] else { return }
        listener?.addMention(item)
        resetMentionTableView()
    }
}

extension CustomCommentInputViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { mentions.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = mentions[safe: indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(MentionCellTableViewCell.self, for: indexPath)
        cell.setupView(item: item)
        return cell
    }
}

extension CustomCommentInputViewController {
    private func searchAccount(text: String, completion: @escaping (([FeedCommentMentionEntity]) -> Void)) {
        
        let request = ProfileEndpoint.searchFollowers(id: getIdUser(), name: text, page: 0)
        Injection.init().provideProfileUseCase().searchAccount(request: request)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { result in
                
                guard let code = result.code, code == "1000" else {
                    print("Not found!")
                    return
                }
                
                let result = result.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                completion(result ?? [])
            } onError: { error in
                print(error.localizedDescription)
                completion([])
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}
