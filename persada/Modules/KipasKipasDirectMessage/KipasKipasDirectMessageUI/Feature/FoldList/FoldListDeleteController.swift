import UIKit
import KipasKipasShared

protocol FoldListDeleteDelegate: AnyObject{
    func foldListDeleteSelectRowAt(convIds:[String] ,row:Int)
}

class FoldListDeleteController:UIViewController {
    weak var delegate: FoldListDeleteDelegate?
    let tableView = UITableView()
    var convIds :[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        view.backgroundColor = UIColor(hexString: "#F2F2F7")
        let header = ChatPopHeader()
        
        view.addSubview(header)
        header.titleLabel.text = "Pilih aksi"
        header.closeImgView.onTap {
            self.dismiss(animated: true)
        }
         
        
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
        tableView.anchors.top.pin(inset: 58)
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


extension FoldListDeleteController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(at: indexPath)
        cell.backgroundColor = .white
        let btn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        if indexPath.row == 0 {
            btn.setImage(.set("ic_chat_pop_delete"))
            cell.textLabel?.text = "Hapus \(convIds.count) pesan"
            cell.textLabel?.textColor = UIColor(hexString: "#FF3B30")
        }else{
            btn.setImage(.set("ic_chat_pop_unfold"))
            cell.textLabel?.text = "Batalkan arsip"
            cell.textLabel?.textColor = .black
        }
        cell.accessoryView = btn
        cell.textLabel?.font =  .roboto(.medium, size: 16)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.foldListDeleteSelectRowAt(convIds:convIds,row:indexPath.row)
    }
     
    
}

// MARK: PanModal
extension FoldListDeleteController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        tableView
    }
    
    public var longFormHeight: PanModalHeight {
        .contentHeight(210)
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
