import UIKit
import KipasKipasDirectMessage


protocol FoldListViewDelegate: AnyObject {
       
    
    func didSelectConversation(_ conversation: TXIMConversation)
    
    func didMoreHandleConversation(_ conversation: TXIMConversation)
    func didUnfoldHandleConversations(_ convIds: [String],isMark:Bool)
    func didUnreadHandleConversations(_ convIds: [String],isMark:Bool)
    func didDeleteHandleConversations(_ convIds: [String])
}

class FoldListView:UIView {
    weak var delegate: FoldListViewDelegate?
    let tableView = UITableView()
    var selectArray: [Int] =  []
    
    var unfoldBtn :UIButton!
    var readBtn :UIButton!
    var deleteBtn :UIButton!
    let spaceView = UIView()
    
    private var bottomConstraint: NSLayoutConstraint!  {
        didSet {
            bottomConstraint.isActive = true
        }
    }
    
    public var conversations: [TXIMConversation] = [] {
        didSet {
            tableView.reloadData()  
        }
    }
     
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    public func reloadData() {
        tableView.reloadData()
    }
     
    
    
    lazy var editButton: UIButton = {
        let editButton = UIButton()
        editButton.setTitle("Ubah", for: .normal)
        editButton.setTitle("Selesai", for: .selected)
        editButton.titleLabel?.font = .roboto(.medium, size: 16)
        editButton.setTitleColor(.chatBlue, for: .normal)
        editButton.frame = CGRect(x: 0, y: 0, width: 65, height: 40)
        editButton.addTarget(self, action: #selector(handleEditButton(_:)), for: .touchUpInside)
        return editButton
    }()
    
    @objc private func handleUnfoldBtn(_ button:UIButton) {
        if !button.isSelected { return }
        let cons = selectArray.map { conversations[$0].convID }
        delegate?.didUnfoldHandleConversations(cons,isMark: false)
        handleEditButton(editButton)
    }
    
    @objc private func handleReadBtn(_ button:UIButton) {
        if !button.isSelected { return }
        var cons:[String]
        if(selectArray.count > 0){
            cons = selectArray.map { conversations[$0] }
                     .filter{$0.isUnread || $0.unreadCount > 0 }
                     .map{$0.convID}
        }else{
            cons =   conversations
                     .filter{$0.isUnread || $0.unreadCount > 0 }
                     .map{$0.convID}
        }
          
        delegate?.didUnreadHandleConversations(cons, isMark: false)
        handleEditButton(editButton)
    }
    
    @objc private func handleDeleteBtn(_ button:UIButton) {
        if !button.isSelected { return }
        let cons = selectArray.map { conversations[$0].convID }
        delegate?.didDeleteHandleConversations(cons)
        handleEditButton(editButton)
    }
    
      
    @objc private func handleEditButton(_ button:UIButton) {
        button.isSelected = !button.isSelected
          selectArray =  []
        if(tableView.isEditing){
            tableView.setEditing(false, animated: false)
        }
        tableView.setEditing(button.isSelected, animated: true)
        bottomConstraint.constant =  button.isSelected ? -79 : -20
        spaceView.backgroundColor = button.isSelected ? .clear : .white
        updateBottomView()
        tableView.reloadData()
    }
     
    func updateBottomView(){
        unfoldBtn.isSelected = false
        deleteBtn.isSelected = false
        
        readBtn.setTitle("Baca semua")
        var hasUnread = false
        conversations.forEach { conv in
            if conv.isUnread || conv.unreadCount > 0{
                hasUnread = true
            }
        }
        readBtn.isSelected = hasUnread
        guard selectArray.count != 0 else { return }
        unfoldBtn.isSelected = true
        deleteBtn.isSelected = true
        
        readBtn.setTitle("Dibaca")
        var hasUnreadSelect = false
        selectArray.forEach { index in
            let conv: TXIMConversation = conversations[index]
            if conv.isUnread || conv.unreadCount > 0{
                hasUnreadSelect = true
            }
        }
        readBtn.isSelected = hasUnreadSelect
    }
    
    
}

//    MARK: -  UI
extension FoldListView {
    
    func configUI(){
//        backgroundColor = .white
        let bottomView = UIStackView()
        bottomView.axis = .vertical
        bottomView.backgroundColor = UIColor(hexString: "#F7F7F7")
        addSubview(bottomView)
        bottomView.anchors.bottom.pin()
        bottomView.anchors.edges.pin( axis: .horizontal)
        bottomView.anchors.height.equal(79)
        
        let contentV = UIStackView()
        contentV.alignment = .fill
        contentV.distribution = .fillEqually
        contentV.spacing = 3
        bottomView.addArrangedSubview(contentV)
         
        
        unfoldBtn = getSubButton(title: "Batalkan arsip")
        unfoldBtn.contentHorizontalAlignment = .left
        unfoldBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        contentV.addArrangedSubview(unfoldBtn)
        unfoldBtn.addTarget(self, action: #selector(handleUnfoldBtn), for: .touchUpInside)
         
        
        readBtn = getSubButton(title: "Baca semua")
        contentV.addArrangedSubview(readBtn)
        readBtn.addTarget(self, action: #selector(handleReadBtn), for: .touchUpInside)
        
        deleteBtn = getSubButton(title: "Hapus") 
        deleteBtn.contentHorizontalAlignment = .right
        deleteBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        contentV.addArrangedSubview(deleteBtn)
        deleteBtn.addTarget(self, action: #selector(handleDeleteBtn), for: .touchUpInside)
        
        
        
        spaceView.backgroundColor = .white
        bottomView.addArrangedSubview(spaceView)
        spaceView.anchors.height.equal(20)
        

        tableView.separatorStyle = .none
        tableView.registerNib(ChatTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        addSubview(tableView)
        tableView.anchors.top.pin()
        tableView.anchors.edges.pin( axis: .horizontal)
        tableView.backgroundColor = .white
        bottomConstraint = tableView.anchors.bottom.pin(inset: 20)
        
        tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    func getSubButton(title:String) -> UIButton{
            let btn = UIButton()
        btn.setTitle(title)
        btn.titleLabel?.font = .roboto(.regular,size: 16)
        btn.setTitleColor(UIColor(hexString: "#BFBFBF"), for: .normal)
        btn.setTitleColor(.chatBlue, for: .selected)
        return btn
    }
}


extension FoldListView:UITableViewDelegate{
      
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle(rawValue: UITableViewCell.EditingStyle.delete.rawValue | UITableViewCell.EditingStyle.insert.rawValue)!
    }
    
      
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            selectArray.append(indexPath.row)
            updateBottomView()
        }else{
            let conversation = conversations[indexPath.row]
            self.delegate?.didSelectConversation(conversation)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else { return }
        if let index = selectArray.firstIndex(of: indexPath.row) {
            selectArray.remove(at: index)
        }
        updateBottomView()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let conversation = conversations[indexPath.row]
        let unread = conversation.unreadCount > 0 || conversation.isUnread
        let readImg =  unread ? "ic_chat_read": "ic_chat_unread"
        let readStr =  unread ? "Dibaca": "Belum Dibaca"
        let readAction:UIContextualAction = UIContextualAction(style: .normal, title: "") {
               [weak self] (action, sourceView, completionHandler) in
            self?.delegate?.didUnreadHandleConversations([conversation.convID], isMark: !conversation.isUnread)
                    completionHandler(true)
                }
        readAction.backgroundColor = UIColor(hexString: "#3478F6")
        readAction.image = createSwipeImage(imgName: readImg, title: readStr,bgColor: "#3478F6")
       
        let config:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [readAction])
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
            self?.delegate?.didUnfoldHandleConversations([conversation.convID], isMark: !conversation.isFold)
                    completionHandler(true)
                }
        foldAction.backgroundColor = UIColor(hexString: "#3478F6")
        foldAction.image = createSwipeImage(imgName:foldImg,title: foldStr, bgColor: "#3478F6")
    
        let actions:[UIContextualAction] = [foldAction,moreAction]
            
        let config:UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: actions)
        config.performsFirstActionWithFullSwipe = true
         return config
    }
    
}

extension FoldListView:UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return conversations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
        let cell: ChatTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        let conversation: TXIMConversation = conversations[indexPath.row]
        cell.configureData(conversations[indexPath.row], isVerified: conversation.isVerified, isPaid: conversation.isPaid)
        cell.selectionStyle = .default
        cell.pinImageV.isHidden = true
        
        return cell
    }
}
