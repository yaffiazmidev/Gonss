import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol ChatMoreDelegate: AnyObject{
    func chatMoreSelectRowAt(conversation: TXIMConversation ,row:Int)
}

class ChatMoreController:UIViewController {
    weak var delegate: ChatMoreDelegate?
    var conversation: TXIMConversation?
    let tableView = UITableView()
    
    init(delegate: ChatMoreDelegate? = nil, conversation: TXIMConversation? = nil) {
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
        header.name = conversation?.nickName ?? ""
        header.faceImgView.isHidden = false
        header.faceImgView.sd_setImage(with: URL(string: conversation?.faceURL ?? ""), placeholderImage: .defaultProfileImageCircle)
        
        
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
        tableView.anchors.top.pin(inset: 68)
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


extension ChatMoreController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(at: indexPath)
        cell.backgroundColor = .white
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        if indexPath.row == 0 {
            if conversation?.isLock == true {
                cell.textLabel?.text = "Buka Blokir \(conversation?.nickName ?? "")"
                btn.setImage(.set("ic_chat_pop_unlock"))
            }else{
                cell.textLabel?.text = "Blok \(conversation?.nickName ?? "")"
                btn.setImage(.set("ic_chat_pop_lock"))
            }
        }else{
            btn.setImage(.set("ic_chat_pop_delete"))
            cell.textLabel?.text = "Hapus Pesan"
        }
        cell.textLabel?.textColor = UIColor(hexString: "#FF3B30")
        cell.accessoryView = btn
        cell.textLabel?.font =  .roboto(.medium, size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.chatMoreSelectRowAt(conversation: conversation!, row:indexPath.row)
    }
     
    
}

// MARK: PanModal
extension ChatMoreController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        tableView
    }
    
    public var longFormHeight: PanModalHeight {
        .contentHeight(217)
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
