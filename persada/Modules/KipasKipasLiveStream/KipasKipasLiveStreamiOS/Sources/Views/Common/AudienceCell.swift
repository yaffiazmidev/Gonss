import UIKit
import KipasKipasShared

final class AudienceCell: UICollectionViewCell {
    
    private let stackLabel = UIStackView()
    
    private(set) var numLabel = UILabel()
    private(set) var imageView = UIImageView()
    
    private let contentVerticalStack = UIStackView()
    private(set) var nameLabel = UILabel()
    private(set) var rankImgView = UIImageView()
    private(set) var coinLabel = UILabel()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.cornerRadius = contentView.frame.size.height / 2
    }
}

// MARK: UI
private extension AudienceCell {
    func configureUI() {
        configureNumLabel()
        configureUserImageView()
        configureStackLabel()
    }
     
    func configureNumLabel(){
        numLabel.font = .roboto(.medium, size: 14)
        numLabel.textColor = .gravel //.watermelon
        contentView.addSubview(numLabel)
        numLabel.anchors.leading.pin()
        numLabel.anchors.centerY.align()
        numLabel.textAlignment = .center
        numLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func configureUserImageView() {
        imageView.backgroundColor = .whiteSmoke
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.image = .defaultProfileImage
        
        contentView.addSubview(imageView)
        imageView.anchors.leading.equal(numLabel.anchors.trailing, constant: 6)
        
        imageView.anchors.height.equal(contentView.anchors.height)
        imageView.anchors.width.equal(imageView.anchors.height)
    }
    
    func configureStackLabel() {
        stackLabel.axis = .horizontal
        stackLabel.spacing = 4
        
        contentView.addSubview(stackLabel)
        stackLabel.anchors.centerY.align()
        stackLabel.anchors.trailing.equal(contentView.anchors.trailing, constant: 0)
        stackLabel.anchors.leading.spacing(15, to: imageView.anchors.trailing)
        configureNameLabel()
        configureCoinLabel()
    }
    
    func configureNameLabel() {
        contentVerticalStack.axis = .vertical
        contentVerticalStack.spacing = 3
        contentVerticalStack.alignment = .leading
        stackLabel.addArrangedSubview(contentVerticalStack)
        
        
        nameLabel.font = .roboto(.medium, size: 14)
        nameLabel.textColor = .gravel
        contentVerticalStack.addArrangedSubview(nameLabel)
         
    }
    
    
    
    func configureCoinLabel() {
        coinLabel.font = .roboto(.medium, size: 10)
        coinLabel.textColor = .gravel 
        stackLabel.addArrangedSubview(coinLabel) 
    }
}

extension AudienceCell{
    
    func setRankImgView(_ senderUserId: String){
        rankImgView.image = nil
        let topSeats:[Any] =  KKCache.common.readArray(key: .topSeatsCache) ?? [""]
        for (index,topSeat) in topSeats.enumerated(){
            let str:String = topSeat as! String
            if (str == senderUserId){
                rankImgView.isHidden = false
                switch index {
                case 0:
                    rankImgView.image = .iconTopOne
                case 1:
                    rankImgView.image = .iconTopTwo
                case 2:
                    rankImgView.image = .iconTopThree
                default:
                    rankImgView.image = UIImage(named: "")
                }
            }
            contentVerticalStack.addArrangedSubview(rankImgView)
            rankImgView.anchors.width.equal(38)
            rankImgView.anchors.height.equal(14) 
        }
    }
    
    public func setRankIcon(_ num : Int){
        switch num {
        case 1:
            rankImgView.image = .iconTopOne
        case 2:
            rankImgView.image = .iconTopTwo
        case 3:
            rankImgView.image = .iconTopThree
        default:
            rankImgView.image = UIImage(named: "")
        }
        
        contentVerticalStack.addArrangedSubview(rankImgView)
        rankImgView.anchors.width.equal(38)
        rankImgView.anchors.height.equal(14)
        if num == 0 || num > 3 {
            rankImgView.isHidden = true
        }else{
            rankImgView.isHidden = false
        }
        
        
        
    }
}
