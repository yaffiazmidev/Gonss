import UIKit
import KipasKipasDirectMessage

public protocol IChatViewController: AnyObject {
    func didConversationsUpdate(_ conversations: [TXIMConversation])
    func displayConversations(_ conversations: [TXIMConversation])
    func displayPaidChatUnreadCount(count: Int32)
    func setFoldCount(count: Int)
    func setFoldUnreadCount(count: Int)
}

public class ChatViewController: UIViewController {
    var isPaidOnly = false
    var completion: ((TXIMUser) -> Void)?
    weak var container: DirectMessageContainerViewController?
    private lazy var mainView: ChatView = {
        let view = ChatView().loadViewFromNib() as! ChatView
        view.delegate = self
        return view
    }()
    
    public var conversations: [TXIMConversation] = [] {
        didSet {
            mainView.conversations = conversations
            mainView.setEmptyState(conversations.isEmpty, title: "Mulai percakapan dengan menekan tombol \"+\"")
            mainView.reloadData()
        }
    }
    
    var interactor: IChatInteractor!
    
    init() {
        super.init(nibName: "ChatViewController", bundle: SharedBundle.shared.bundle)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    private lazy var timestampStorage = TimestampStorage()
    
    public override func loadView() {
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
}

extension ChatViewController: ChatViewDelegate {
    func didNavToFoldList(){
        container?.didNavToFoldList(isPaidOnly:isPaidOnly )
    }
    
    func didReadHandleConversation(_ conversation: TXIMConversation){
        if conversation.unreadCount > 0 || conversation.isUnread {
            container?.clearUnreadCount(conversation)
        }else{
            container?.addUnreadMark(conversationId: conversation.convID)
        }
        
    }
    func didPinHandleConversation(_ conversation: TXIMConversation){
        let pinConvs = self.conversations.filter({ $0.isPin })
        if !conversation.isPin &&  pinConvs.count >= 3 {
             presentAlert(title: "", message: "Anda hanya dapat menyematkan maksimal 3 chat")
            return
        }
        container?.pinConversation(conversation: conversation)
    }
    func didMoreHandleConversation(_ conversation: TXIMConversation){
        let moreVc =  ChatMoreController.init(delegate: self, conversation: conversation)
        self.presentPanModal(moreVc)
    }
    func didFoldHandleConversation(_ conversation: TXIMConversation){
        container?.foldConversation(conversation: conversation)
    }
    
    func didSearchConversation(by keyword: String?) {
        interactor.searchConversation(with: keyword ?? "")
    }
    
    func didSelectConversation(_ conversation: TXIMConversation) {
        let user: TXIMUser = TXIMUser(userID: conversation.userID, userName: conversation.nickName, faceURL: conversation.faceURL, isVerified: conversation.isVerified)
        completion?(user)
        container?.clearUnreadCount(conversation)
    }
    
    func handleLoadMoreConversations() {
        container?.loadMoreConversations()
    }
}

extension ChatViewController:ChatMoreDelegate,ChatLockDelegate,ChatDeleteDelegate{
    func chatMoreSelectRowAt(conversation: TXIMConversation ,row:Int){
        if row == 0 {
            if conversation.isLock == true { //unlock
                container?.didRemoveDefriend(conversation: conversation)
            }else{  // lock or report
                self.dismiss(animated: true)
                let vc =    ChatLockController(delegate: self,conversation: conversation)
                self.presentPanModal(vc)
            }
        }else{ //delete and fold
            self.dismiss(animated: true)
            let vc =    ChatDeleteController(delegate: self,conversation: conversation)
            self.presentPanModal(vc)
        }
    }
    
    func chatLockSelectRowAt(conversation: TXIMConversation, row: Int) {
         // 1 report  0 lock
        container?.didDefriend(with: conversation, report: row == 1 )
    }
    
    func chatDeleteSelectRowAt(conversation: TXIMConversation, row: Int) {
        self.dismiss(animated: true)
        if row == 0 {
            container?.didDeleteConversations([conversation.convID])
        }else{
            container?.foldConversation(conversation: conversation)
        }
    }
}



extension ChatViewController: IChatViewController {
     
    public func didConversationsUpdate(_ conversations: [TXIMConversation]) {
        interactor.didConversationsUpdate(conversations)
    }
    
    public func displayConversations(_ conversations: [TXIMConversation]) {
        self.conversations = conversations
    }
    
    public func displayPaidChatUnreadCount(count: Int32) {
        container?.didPaidChatUnreadCountUpdated(count: count)
    }
    
    public func setFoldCount(count: Int) {
        mainView.setFoldHeaderShow(isShow: count > 0)
    }
    
    public func setFoldUnreadCount(count: Int) {
        mainView.setFoldUnreadConvsCount(count: count)
    }
    
    var showDragIndicator: Bool{
        false
    }
}
