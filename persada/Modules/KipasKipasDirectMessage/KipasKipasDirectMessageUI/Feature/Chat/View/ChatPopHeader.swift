import UIKit

class ChatPopHeader: UIView{
    
    let titleLabel = UILabel()
    let closeImgView = UIImageView()
    let faceImgView = UIImageView()
    let nameLabel = UILabel()
//    let tableView = UITableView()
    var name:String = ""{
        didSet{
            topConstraint.constant = 15
            nameLabel.text = name
        }
    }
    
    private var topConstraint: NSLayoutConstraint!  {
        didSet {
            topConstraint.isActive = true
        }
    }
      
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, 0, UIScreen.width, 45))
        setupHeader()
    }
      
    func setupHeader(){
        titleLabel.text = ""
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.font = .roboto(.medium, size: 16)
        addSubview(titleLabel)
        titleLabel.anchors.top.pin(inset: 17.5)
        titleLabel.anchors.centerX.align()
        titleLabel.anchors.width.equal(UIScreen.width - 40*2)
         
        closeImgView.image = .set("ic_chat_pop_close")
        addSubview(closeImgView)
        closeImgView.anchors.right.pin(inset: 15)
        topConstraint = closeImgView.anchors.top.pin(inset: 9)
        closeImgView.anchors.width.equal(28)
        closeImgView.anchors.height.equal(28)
        closeImgView.onTap { [weak self] in
            self?.removeFromSuperview()
        }
        
         
        addSubview(faceImgView)
        faceImgView.layer.borderColor = UIColor(hexString: "#C4C4C4").cgColor
        faceImgView.layer.borderWidth = 1
        faceImgView.layer.cornerRadius = 19
        faceImgView.layer.masksToBounds = true
        faceImgView.anchors.top.pin(inset: 15)
        faceImgView.anchors.leading.pin(inset: 15)
        faceImgView.anchors.width.equal(38)
        faceImgView.anchors.height.equal(38)
        faceImgView.isHidden = true
        
        nameLabel.text = ""
        nameLabel.textColor = .black
        nameLabel.font = .roboto(.medium, size: 16)
        addSubview(nameLabel)
        nameLabel.anchors.leading.equal(faceImgView.anchors.trailing,constant: 11)
        nameLabel.anchors.trailing.pin(inset: 50)  // 12 + 28 + 15
        nameLabel.anchors.centerY.equal(faceImgView.anchors.centerY)
    }
}

 
