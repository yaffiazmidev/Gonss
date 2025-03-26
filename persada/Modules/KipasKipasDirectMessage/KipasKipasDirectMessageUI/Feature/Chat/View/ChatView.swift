//
//  ChatView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 05/08/23.
//

import UIKit
import KipasKipasDirectMessage

protocol ChatViewDelegate: AnyObject {
    func didReadHandleConversation(_ conversation: TXIMConversation)
    func didPinHandleConversation(_ conversation: TXIMConversation)
    func didMoreHandleConversation(_ conversation: TXIMConversation)
    func didFoldHandleConversation(_ conversation: TXIMConversation)
    func didSelectConversation(_ conversation: TXIMConversation)
    func handleLoadMoreConversations()
    func didSearchConversation(by keyword: String?)
    func didNavToFoldList()
}

class ChatView: UIView {
    
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarContainerStackView: UIStackView!
    
    @IBOutlet weak var searchContainer: UIStackView!
    
    let foldUnreadConvsCountL = UILabel()
    weak var delegate: ChatViewDelegate?
    public var conversations: [TXIMConversation] = []
    private lazy var timestampStorage = TimestampStorage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setupTableView()
        setupSearchBarContainer()
    }
    
    private func setupView() {
        searchBarTextField.delegate = self
        searchBarTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
        tableView.setLoadingActivity()
        tableView.registerNib(ChatTableViewCell.self)
        
        
        tableView.tableHeaderView = UIView() 
    }
    
    private func setupFoldHeader() -> UIView{
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 55))
        let imgV = UIImageView()
        imgV.image = .set("ic_chat_grayfold")
        header.addSubview(imgV)
        imgV.anchors.leading.pin(inset: 30)
        imgV.anchors.centerY.align()
        imgV.anchors.width.equal(30)
        imgV.anchors.height.equal(30)
        let titleL = UILabel()
        titleL.text = "Diarsipkan"
        titleL.textColor = .black
        titleL.font = .roboto(.medium, size: 16)
        header.addSubview(titleL)
        titleL.anchors.leading.equal(imgV.anchors.trailing,constant: 29)
        titleL.anchors.centerY.align()
          
        foldUnreadConvsCountL.textColor = UIColor(hexString: "#3478F6")
        foldUnreadConvsCountL.font = .roboto(.regular, size: 14)
        header.addSubview(foldUnreadConvsCountL)
        foldUnreadConvsCountL.anchors.centerY.align()
        foldUnreadConvsCountL.anchors.trailing.pin(inset: 17)
        
        let lineL = UILabel()
        header.addSubview(lineL)
        lineL.backgroundColor = .softPeach
        lineL.anchors.height.equal(1)
        lineL.anchors.leading.equal(titleL.anchors.leading)
        lineL.anchors.trailing.pin()
        lineL.anchors.bottom.pin()
        header.onTap { [weak self] in
            self?.delegate?.didNavToFoldList()
        }
        return header
    }
    
    private func setupSearchBarContainer() {
        searchBarContainerStackView.layer.cornerRadius = 12
    }
    
    private func setHideSearchContainer(_ isHidden: Bool) {
        guard self.searchContainer.isHidden != isHidden else {
            return
        }
        UIView.animate(
            withDuration: 0.3,
            delay: 0.1,
            options: .transitionCrossDissolve,
            animations: {
            self.searchContainer.isHidden = isHidden
        }, completion: { _ in
            self.searchContainer.isHidden = isHidden
        })
    }
    
    @objc private func didEditingChanged(_ textField: UITextField) {
        searchBarTextField.addDelayedAction(with: 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.didSearchConversation(by: textField.text)
        }
    }
    
    public func setEmptyState(_ isEmpty: Bool, title: String) {
        isEmpty ? tableView.setEmptyView(title) : tableView.deleteEmptyView()
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func setFoldHeaderShow(isShow:Bool) {
       tableView.tableHeaderView = isShow ? setupFoldHeader() : UIView()
         
    }
    
    public func setFoldUnreadConvsCount(count:Int) {
        foldUnreadConvsCountL.text = count > 0 ? "\(count)" : ""
    }
    
    
    
}

extension ChatView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return true
    }
}

extension ChatView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let conversation = conversations[indexPath.row]
        let unread = conversation.unreadCount > 0 || conversation.isUnread
        let readImg =  unread ? "ic_chat_read": "ic_chat_unread"
        let readStr =  unread ? "Dibaca": "Belum Dibaca"
        let readAction:UIContextualAction = UIContextualAction(style: .normal, title: "") {
               [weak self] (action, sourceView, completionHandler) in
                    self?.delegate?.didReadHandleConversation(conversation)
                    completionHandler(true)
                }
        readAction.backgroundColor = UIColor(hexString: "#3478F6")
        readAction.image = createSwipeImage(imgName: readImg, title: readStr,bgColor: "#3478F6")
        
        let pinImg = conversation.isPin ? "ic_chat_unpin" : "ic_chat_pin"
        let pinStr = conversation.isPin ? "Lepaskan" : "Sematkan"
        let pinAction:UIContextualAction = UIContextualAction(style: .normal, title: "") {
                [weak self](action, sourceView, completionHandler) in
                    self?.delegate?.didPinHandleConversation(conversation)
                    completionHandler(true)
                }
        pinAction.backgroundColor = UIColor(hexString: "#C8C8CC")
        pinAction.image = createSwipeImage(imgName: pinImg,title: pinStr, bgColor: "#C8C8CC")
    
        var actions:[UIContextualAction] = [readAction]
        
        if !conversation.isFold {
            actions.append(pinAction)
        }
        let config:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = true
         return config
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let conversation = conversations[indexPath.row]
        let moreAction:UIContextualAction = UIContextualAction(style: .normal, title: "") { 
               [weak self](action, sourceView, completionHandler) in
                    self?.delegate?.didMoreHandleConversation(conversation)
                    completionHandler(true)
                }
        moreAction.backgroundColor = UIColor(hexString: "#C8C8CC")
        moreAction.image = createSwipeImage(imgName: "ic_chat_more", title: "Lainnya",bgColor: "#C8C8CC")
         
        let foldImg = conversation.isFold ? "ic_chat_unfold" : "ic_chat_fold"
        let foldStr = conversation.isFold ? "Batalkan arsip" : "Arsipkan"
        let foldAction:UIContextualAction = UIContextualAction(style: .normal, title: "") {
               [weak self](action, sourceView, completionHandler) in
                     self?.delegate?.didFoldHandleConversation(conversation)
                    completionHandler(true)
                }
        foldAction.backgroundColor = UIColor(hexString: "#3478F6")
        foldAction.image = createSwipeImage(imgName:foldImg,title: foldStr, bgColor: "#3478F6")
    
        let actions:[UIContextualAction] = [foldAction,moreAction]
            
        let config:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = true
         return config
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = conversations[indexPath.row]
        delegate?.didSelectConversation(conversation)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            delegate?.handleLoadMoreConversations()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > scrollView.frame.height || self.searchContainer.isHidden else {
            return
        }
        setHideSearchContainer(!tableView.isAtTop)
    }
}

extension ChatView: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let conversation: TXIMConversation = conversations[indexPath.row]
        cell.configureData(conversations[indexPath.row], isVerified: conversation.isVerified, isPaid: conversation.isPaid)
        
        return cell
    }
}
private extension UIScrollView {
    
    var isAtTop: Bool {
        return contentOffset.y <= verticalOffsetForTop
    }
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    
    var verticalOffsetForTop: CGFloat {
        let topInset = contentInset.top
        return -topInset
    }
    
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
    
}
 
