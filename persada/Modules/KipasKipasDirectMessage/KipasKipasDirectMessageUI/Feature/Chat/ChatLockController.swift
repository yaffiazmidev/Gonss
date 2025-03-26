import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol ChatLockDelegate: AnyObject{
    func chatLockSelectRowAt(conversation: TXIMConversation ,row:Int)
}

class ChatLockController:UIViewController {
    weak var delegate: ChatLockDelegate?
    var conversation: TXIMConversation?
    let tableView = UITableView()
    
    init(delegate: ChatLockDelegate? = nil, conversation: TXIMConversation? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.conversation = conversation
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        view.backgroundColor = UIColor(hexString: "#F2F2F7")
        let header = ChatPopHeader()
        
        view.addSubview(header)
        header.closeImgView.onTap {
            self.dismiss(animated: true)
        }
        header.titleLabel.text = "Blok \" \(conversation?.nickName ?? "")  \""
        
        
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 12
        view.addSubview(textView)
        textView.font = .roboto(.regular, size: 12)
        textView.textColor = .black
        textView.textContainerInset = UIEdgeInsets(top: 21, left: 15, bottom: 21, right: 15)
        
        let textStr = "Kontak yang bi blok tidak akan bisa menelfon kamu atau mengirimi kamu pesan.\n\n Jika kamu mem-blok dan melaporkan kontak ini, 5 pesan terakhir akan diteruskan ke DM dan percakapan kamu dengan kotan ini akan dihapus."
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 1
        textView.attributedText = NSAttributedString(
            string: textStr, attributes: [.paragraphStyle: style]
        )
        
        textView.anchors.top.pin(inset: 58)
        textView.anchors.edges.pin(insets: 15,axis:.horizontal)
        textView.anchors.height.equal(130)
         
        
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 12
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.registerCell(UITableViewCell.self)
        tableView.rowHeight = 54
        tableView.delegate = self
        tableView.dataSource = self
        tableView.anchors.top.equal(textView.anchors.bottom, constant: 12)
        tableView.anchors.edges.pin(insets: 15, axis: .horizontal)
        tableView.anchors.height.equal(108)
        
       let lineL = UILabel()
        lineL.backgroundColor = .softPeach
        view.addSubview(lineL)
        lineL.anchors.edges.pin(insets: 15, axis: .horizontal)
        lineL.anchors.centerY.equal(tableView.anchors.centerY)
        lineL.anchors.height.equal(1)
    }
    
}


extension ChatLockController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(at: indexPath)
        cell.backgroundColor = .white
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        if indexPath.row == 0 {
            btn.setImage(.set("ic_chat_pop_lock"))
            cell.textLabel?.text = "Blokir"
        }else{
            btn.setImage(.set("ic_chat_pop_report"))
            cell.textLabel?.text = "Blok dan Laporkan"
        }
        cell.textLabel?.textColor = UIColor(hexString: "#FF3B30")
        cell.accessoryView = btn
        cell.textLabel?.font =  .roboto(.medium, size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.chatLockSelectRowAt(conversation: conversation!, row:indexPath.row)
    }
     
    
}

// MARK: PanModal
extension ChatLockController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        tableView
    }
    
    public var longFormHeight: PanModalHeight {
        .contentHeight(347)
    }
    
    public var shortFormHeight: PanModalHeight {
        longFormHeight
    }
    
    public var panModalBackgroundColor: UIColor {
        UIColor.init(hexString: "#000000", alpha: 0.5)
    }
    var showDragIndicator: Bool{
        false
    }
}
