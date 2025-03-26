//
//  PopUpTextViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 18/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift

protocol PopUpTextViewControllerDelegate: AnyObject {
    func textView(result: String)
}

class PopUpTextViewController: UIViewController {
    
    
    
    @IBOutlet weak var mentionTableView: UITableView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    weak var delegate: PopUpTextViewControllerDelegate?
    private var text = ""
    private var placeholder = ""
    private let disposeBag = DisposeBag()
    private let concurrentBackground = ConcurrentDispatchQueueScheduler.init(qos: .background)
    private var listener: MentionListener?
    private var filterString: String = ""
    private var mentions: [FeedCommentMentionEntity] = []
    
    private var mentionsList: [FeedCommentMentionEntity] {
        guard !mentions.isEmpty, filterString != "" else { return [] }
        let keyword = filterString.lowercased()
        return mentions
            .filter { $0.slug.contains(keyword) }
            .sorted { ($0.slug.hasPrefix(keyword) ? 0 : 1) < ($1.slug.hasPrefix(keyword) ? 0 : 1) }
    }
    
    private let mentionAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: UIColor.systemBlue),
        Attribute(name: .font, value: UIFont(name: "Roboto-Bold", size: 12)!),
    ]
    
    private let defaultAttributes: [AttributeContainerMention] = [
        Attribute(name: .foregroundColor, value: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)),
        Attribute(name: .font, value: UIFont(name: "Roboto-Regular", size: 12)!),
    ]
    
    init(text: String = "", placeholder: String = "Ketik sesuatu..") {
        super.init(nibName: nil, bundle: nil)
        self.text = text
        self.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMentionTableView()
        setupComponent()
        handleOnTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 15
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculateSuggestionAndTextViewHeight()
    }
    
    private func handleOnTap() {
        overlayView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.inputTextView.resignFirstResponder()
            self.dismiss(animated: true) {
                self.delegate?.textView(result: self.inputTextView.text ?? "")
            }
        }
    }
    
    private func setupComponent() {
        inputTextView.text = text
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !text.isEmpty
        inputTextView.textColor = inputTextView.text.isEmpty ? .clear : .black
        inputTextView.becomeFirstResponder()
    }
    
    private func calculateSuggestionAndTextViewHeight() {
        inputTextView.inputAccessoryView = nil
        
        let maxHeight:CGFloat = 150
        let maxTextHeight:CGFloat = 150
        let minTextHeight:CGFloat = 28
        
        var resizeHeight = mentionTableView.contentSize.height
        var resizeTextHeight = inputTextView.contentSize.height
        if resizeHeight > maxHeight { resizeHeight = maxTextHeight }
        if resizeTextHeight > maxTextHeight { resizeTextHeight = maxTextHeight }
        if resizeTextHeight < minTextHeight { resizeTextHeight = minTextHeight }
        
        mentionTableViewHeightConstraint.constant = resizeHeight
        textViewHeightConstraint.constant = resizeTextHeight
    }
    
    private func setupMentionTableView() {
        mentionTableView.backgroundColor = .white
        mentionTableView.delegate = self
        mentionTableView.dataSource = self
        mentionTableView.rowHeight = UITableView.automaticDimension
        mentionTableView.register(UINib(nibName: "MentionCellTableViewCell", bundle: nil), forCellReuseIdentifier: "MentionCellTableViewCell")
        
        let mentionsListener = MentionListener(mentionsTextView: inputTextView,
                                               mentionTextAttributes: { _ in self.mentionAttributes },
                                               defaultTextAttributes: defaultAttributes,
                                               spaceAfterMention: true,
                                               hideMentions: hideMentions,
                                               didHandleMentionOnReturn: didHandleMentionOnReturn,
                                               showMentionsListWithString: showMentionsListWithString)
        inputTextView.delegate = mentionsListener
        listener = mentionsListener
    }
    
    private func hideMentions() { filter("") }
    
    private func didHandleMentionOnReturn() -> Bool { return false }
    
    private func showMentionsListWithString(mentionsString: String, trigger _: String) {
        filter(mentionsString)
    }
    
    private func filter(_ string: String) {
        inputTextView.textColor = inputTextView.text.isEmpty ? .clear : .black
        placeholderLabel.isHidden = !inputTextView.text.isEmpty
        searchAccount(text: string)
        filterString = string
        mentionTableView.reloadData()
        viewDidLayoutSubviews()
    }
    
    private func searchAccount(text: String) {
        let request = ProfileEndpoint.searchFollowers(id: getIdUser(), name: text, page: 0)
        Injection.init().provideProfileUseCase().searchAccount(request: request)
            .subscribeOn(concurrentBackground)
            .observeOn(MainScheduler.instance)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                
                guard let code = result.code, code == "1000" else {
                    print("Not found!")
                    return
                }
                
                let result = result.data?.content?.compactMap({ FeedCommentMentionEntity(follower: $0) })
                self.mentions = result ?? []
                self.viewDidLayoutSubviews()
            } onError: { error in
                print(error.localizedDescription)
            } onCompleted: {
            }.disposed(by: disposeBag)
    }
}

extension PopUpTextViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        listener?.addMention(mentionsList[indexPath.row])
    }
}

extension PopUpTextViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { mentionsList.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MentionCellTableViewCell", for: indexPath) as! MentionCellTableViewCell
        let mention = mentionsList[indexPath.row]
        cell.backgroundColor = .white
        cell.nameLabel.textColor = .black
        cell.nameLabel.text = String(mention.name.dropFirst())
        cell.usernameLabel.text = mention.fullName
        cell.pictureImageView.loadImage(at: mention.photoUrl)
        return cell
    }
}
