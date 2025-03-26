//
//  SubcommentViewController.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 14/09/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift

class SubcommentViewController: BaseController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var mentionTableView: UITableView!
    @IBOutlet weak var commentInputTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentInputTextViewPlaceholderLabel: UILabel!
    @IBOutlet weak var commentInputTextView: UITextView! {
        didSet {
            commentInputTextView.layer.cornerRadius = 8
            commentInputTextView.layer.borderWidth = 1
            commentInputTextView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    var viewModel: SubcommentViewModel?
    private let disposeBag = DisposeBag()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
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
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.fetchSubcomment()
        setupTableView()
        setupMentionTableView()
        bindViewModel()
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
    
    func bindViewModel() {
        viewModel?.subCommentResult.subscribe(onNext: { [weak self] data in
            let filterIsReported = data?.data?.commentSubs?.filter( { $0.isReported == false }) ?? []
            let sortedWithCreateDate = filterIsReported.sorted(by: { $0.createAt ?? 0 > $1.createAt ?? 0 })
            self?.viewModel?.subcommentDataSource?.subcomments = sortedWithCreateDate
            self?.tableView.reloadData()
            self?.stopLoading()
            self?.tableView.scrollToBottom()
        }).disposed(by: disposeBag)
        
        viewModel?.filterFollower.bind(onNext: { [weak self] data in
            self?.mentions = data
            self?.mentionTableView.reloadData()
            self?.viewDidLayoutSubviews()
        }).disposed(by: disposeBag)
        
        sendCommentButton.rx.tap
            .throttle(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .bind { [weak self] in
                self?.handleSendSubComment()
        }.disposed(by: disposeBag)
    }
    
    func setupMentionTableView() {
        mentionTableView.backgroundColor = .white
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
    
    func setupTableView() {
        tableView.refreshControl = refreshControl
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SubcommentTableViewCell.cellNib, forCellReuseIdentifier: SubcommentTableViewCell.identifier)
    }
    
    @objc private func handleRefresh() {
        viewModel?.fetchSubcomment()
        refreshControl.endRefreshing()
    }
    
    func routeToProfile(_ id: String,_ type: String) {
        let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id, type: type))
        controller.setProfile(id: id, type: type)
        controller.bindNavigationBar("", true)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func routeToHashtag(_ hashtag: String){
        let hashtagVC = HashtagViewController(hashtag: hashtag)
        navigationController?.pushViewController(hashtagVC, animated: true)
    }
    
    func handleTapMention(_ text: String) {
        viewModel?.mention(word: text) { [weak self] userID, userType in
            self?.routeToProfile(userID, userType)
        } onError: { error in
            if error == "Data Not Found" {
                self.navigationController?.push(EmptyUserProfileViewController())
            } else {
                self.showErrorAlert(error: error)
            }
        }
    }
    
    func handleSendSubComment() {
        view.endEditing(true)
        startLoading()
        let subcomment = viewModel?.subcommentDataSource
        viewModel?.addSubcomment(subcomment?.postId ?? "", subcomment?.id ?? "", value: commentInputTextView.text,
                                      onSuccess: { [weak self] isSuccess in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if isSuccess {
                    self?.commentInputTextView.text = nil
                    self?.viewModel?.fetchSubcomment()
                } else {
                    self?.showErrorAlert(error: "Failed to send meesage!")
                }
                self?.stopLoading()
            }
        })
    }
}

extension SubcommentViewController {
    func hideMentions() {
        filter("")
    }
    
    func didHandleMentionOnReturn() -> Bool { return false }
    
    func showMentionsListWithString(mentionsString: String, trigger _: String) {
        filter(mentionsString)
    }
}

extension SubcommentViewController: UITableViewDelegate {
    func filter(_ string: String) {
        sendCommentButton.image(.get(commentInputTextView.text.isEmpty ? .iconFeatherSendGray : .iconFeatherSend))
        sendCommentButton.isEnabled = !commentInputTextView.text.isEmpty
        commentInputTextViewPlaceholderLabel.isHidden = !commentInputTextView.text.isEmpty
        
        viewModel?.searchAccount(string)
        
        filterString = string
        mentionTableView.reloadData()
        viewDidLayoutSubviews()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == mentionTableView {
            listener?.addMention(mentionsList[indexPath.row])
        }
    }
}

extension SubcommentViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView != mentionTableView ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView != mentionTableView {
            return section != 0 ? viewModel?.subcommentDataSource?.subcomments.count ?? 0 : 1
        } else {
            return mentionsList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView != mentionTableView {
            if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCustomCell(with: SubcommentTableViewCell.self, indexPath: indexPath)
                let commentHeader = viewModel?.subcommentDataSource?.commentHeader
                cell.isHeader = true
                cell.deleteLabel.isHidden = true
                cell.setupCommentHeaderView(item: viewModel?.subcommentDataSource?.commentHeader)
                cell.headerCommentLabel.handleMentionTap { [weak self] (text) in
                    self?.handleTapMention(text)
                }
                
                cell.headerCommentLabel.handleHashtagTap { [weak self] (hashtag) in
                    self?.routeToHashtag(hashtag)
                }
                
                cell.userImageView.onTap {
                    self.routeToProfile(commentHeader?.userId ?? "", commentHeader?.userType ?? "")
                }
                
                cell.usernameLabel.onTap {
                    self.routeToProfile(commentHeader?.userId ?? "", commentHeader?.userType ?? "")
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCustomCell(with: SubcommentTableViewCell.self, indexPath: indexPath)
                let item = viewModel?.subcommentDataSource?.subcomments[indexPath.row]
                cell.isHeader = false
                cell.setupCommentBodyView(item: item)
                
                cell.commentLabel.handleMentionTap { [weak self] (text) in self?.handleTapMention(text) }
                cell.commentLabel.handleHashtagTap { [weak self] (hashtag) in self?.routeToHashtag(hashtag) }
                
                cell.likeIcon.onTap {
                    cell.likeIcon.transform = cell.likeIcon.transform.scaledBy(x: 0.8, y: 0.8)
                    UIView.animate(withDuration: 0.3) {
                        cell.likeIcon.transform = CGAffineTransform.identity
                    }
                    self.viewModel?.requestLike(postId: self.viewModel?.subcommentDataSource?.postId ?? "",
                                                id: item?.id ?? "",
                                                status: item?.isLike == true ? "unlike" : "like")
                }
                
                
                cell.deleteLabel.onTap {
                    let cancelAction = UIAlertAction(title: "Batal", style: .cancel, handler: { _ in

                    })
                    let actions = [UIAlertAction(title: "Ya", style: .default, handler: { _ in
                        self.viewModel?.deleteSubComment(id: item?.id ?? "")
                    }), cancelAction]

                    self.displayAlert(with: "Hapus Komentar", message: "Yakin ingin menghapus komentar ini?", actions: actions)
                    cancelAction.setValue(UIColor.warning, forKey: "titleTextColor")
                }
                
                cell.userImageView.onTap {
                    self.routeToProfile(item?.account?.id ?? "", item?.account?.accountType ?? "")
                }
                
                cell.usernameLabel.onTap {
                    self.routeToProfile(item?.account?.id ?? "", item?.account?.accountType ?? "")
                }
                
                cell.deleteLabel.isHidden = getUsername() != item?.account?.username ?? ""
                
                return cell
            }
        } else {
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
}


extension SubcommentViewController: AlertDisplayer {
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
