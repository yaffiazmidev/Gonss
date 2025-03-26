 
import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

public final class FoldListController: UIViewController, NavigationAppearance {
    
    let tableView = UITableView() 
    var selectArray: [Int] =  []
    var completion: ((String, String, String, Bool, Bool) -> Void)?
    var interactor: FoldListInteractor!
    
    private let userId: String
    private let userSig: String
//    private var isPaid = false
    
    
    public init(
        userId: String,
        userSig: String,
//        isPaid: Bool = false,
        completion: @escaping ((String, String, String, Bool, Bool) -> Void)
    ) {
        self.userId = userId
        self.userSig = userSig
//        self.isPaid = isPaid
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var bottomConstraint: NSLayoutConstraint!  {
        didSet {
            bottomConstraint.isActive = true
        }
    }
    
    public var conversations: [TXIMConversation] = [] {
        didSet {
            mainView.conversations = conversations
            mainView.reloadData()
            if conversations.count == 0 {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private lazy var mainView: FoldListView = {
        let view = FoldListView()
        view.delegate = self
        return view
    }()
    
    public override func loadView() {
        self.view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        interactor.loadMoreConversations()
        
         self.title = "Diarsipkan"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainView.editButton)
    }
     
   
    
}

//    MARK: -  viewDelegat
extension FoldListController:FoldListViewDelegate{
    func didSelectConversation(_ conversation: TXIMConversation) {
        
        completion?(conversation.userID, conversation.nickName, conversation.faceURL, conversation.isVerified, conversation.isPaid)
        
        interactor.clearUnreadCount(conversation)
    }
    
    func didMoreHandleConversation(_ conversation: TXIMConversation) {
        let moreVc =  ChatMoreController.init(delegate: self, conversation: conversation)
        self.presentPanModal(moreVc)
    }
    
    func didUnfoldHandleConversations(_ conversations: [String], isMark: Bool) {
        interactor.didUnfoldHandleConversations(conversations, isMark: isMark)
    }
    
    func didUnreadHandleConversations(_ conversations: [String], isMark: Bool) {
        interactor.didUnreadHandleConversations(conversations, isMark: isMark)
    }
    
    func didDeleteHandleConversations(_ convIds: [String]){
        let foldListDelete = FoldListDeleteController()
        foldListDelete.convIds = convIds
        foldListDelete.delegate = self
        self.presentPanModal(foldListDelete)
    }
     
}

extension FoldListController:FoldListDeleteDelegate,ChatMoreDelegate,ChatLockDelegate,ChatDeleteDelegate{
     
    func chatMoreSelectRowAt(conversation: TXIMConversation, row: Int) {
         if row == 0 {
            if conversation.isLock == true { //unlock
                KKDefaultLoading.shared.show(message: "Membuka blokir...")
                interactor.removeDefriend(conversation: conversation)
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
    
    func chatDeleteSelectRowAt(conversation: TXIMConversation, row: Int) {
        self.dismiss(animated: true)
        if row == 0 { // delete
            interactor.didDeleteConversations([conversation.convID])
        }else{  // unfold
            interactor.didUnfoldHandleConversations([conversation.convID], isMark: false)
        }
    }
    
    func chatLockSelectRowAt(conversation: TXIMConversation, row: Int) {
        KKDefaultLoading.shared.show(message: "Memblokir...")
        // 0 lock  1 lock and report
        interactor.defriend(with: conversation, report: row == 1)
    }
    
    func foldListDeleteSelectRowAt(convIds:[String] ,row:Int){
        self.dismiss(animated: true)
        if row == 1 {  // unfold
            interactor.didUnfoldHandleConversations(convIds, isMark: false)
        }else{ //delete
            interactor.didDeleteConversations(convIds)
        }
    }
}

//    MARK: - interactor
extension FoldListController:FoldListInteractorDelegate{
    func lockConversationSuccess(isSucess: Bool, message: String) {
        KKDefaultLoading.shared.hide()
        self.dismiss(animated: true)
        
        if(!isSucess){
            presentAlert(title: "Error", message: message)
        }
    }
    
    func didConversationsUpdate(_ conversations: [KipasKipasDirectMessage.TXIMConversation]) {
        self.conversations = conversations
        tableView.reloadData()
    }
    
    
}
 
