import UIKit
import KipasKipasShared
import KipasKipasLiveStream

final class LiveRoomChatCell: UITableViewCell {
    
    private let container = UIStackView()
    
    private let userImageView = UIImageView()
    private let actionImageView = UIImageView()
    
    private let labelStack = UIStackView()
    private let userStack = UIStackView()
    private let nameLabel = UILabel()
    private let rankImgView = UIImageView()
    private let messageLabel = UILabel()
    
    private var viewModel: LiveRoomChatViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.cancel()
        userImageView.image = nil
        actionImageView.image = nil
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    // MARK: API
    func configure(with viewModel: LiveRoomChatViewModel) {
        switch viewModel.messageType {
        case .LIKE:
            container.alignment = .center
            userImageView.isHidden = true
            actionImageView.image = .iconMemberLiked
            actionImageView.isHidden = false
            nameLabel.isHidden = true
            messageLabel.text = viewModel.message
            rankImgView.isHidden = true
        case .JOIN:
            container.alignment = .center
            userImageView.isHidden = true
            actionImageView.image = .iconMemberJoined
            actionImageView.isHidden = false
            nameLabel.isHidden = true
            messageLabel.text = viewModel.message
            rankImgView.isHidden = true
        case .WELCOME:
            container.alignment = .top
            userImageView.isHidden = true
            actionImageView.image = .iconMemberWelcome
            actionImageView.isHidden = false
            nameLabel.isHidden = true
            messageLabel.text = viewModel.message
            rankImgView.isHidden = true
        case .CHAT:
            container.alignment = .top
            actionImageView.isHidden = true
            userImageView.setImage(with: viewModel.senderAvatarURL, placeholder: .defaultProfileImage)
            userImageView.isHidden = false
            nameLabel.text = viewModel.senderUsername
            nameLabel.isHidden = false
            messageLabel.text = viewModel.message
            rankImgView.isHidden = true
            setRankImgView(viewModel)
        }
       
    }
    
    func setRankImgView(_ viewModel: LiveRoomChatViewModel){
        let topSeats:[Any] =  KKCache.common.readArray(key: .topSeatsCache) ?? [""]
        for (index,topSeat) in topSeats.enumerated(){
            let str:String = topSeat as! String
            if (str == viewModel.senderUserId){
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
        }
    }
}

// MARK: UI
private extension LiveRoomChatCell {
    func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        configureContainerView()
    }
    
    func configureContainerView() {
        container.backgroundColor = .clear
        container.alignment = .top
        container.spacing = 8
        
        contentView.addSubview(container)
        container.anchors.top.pin(inset: 10)
        container.anchors.edges.pin(axis: .horizontal)
        container.anchors.bottom.pin()
        
        configureUserImageView()
        configureActionImageView()
        configureLabelStack()
    }
    
    func configureUserImageView() {
        userImageView.layer.cornerRadius = 26 / 2
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.isHidden = true
        
        container.addArrangedSubview(userImageView)
        userImageView.anchors.width.equal(26)
        userImageView.anchors.height.equal(26)
    }
    
    func configureActionImageView() {
        actionImageView.layer.cornerRadius = 26 / 2
        actionImageView.clipsToBounds = true
        actionImageView.layer.masksToBounds = true
        actionImageView.contentMode = .scaleAspectFill
        actionImageView.isHidden = true
        
        container.addArrangedSubview(actionImageView)
        actionImageView.anchors.width.equal(26)
        actionImageView.anchors.height.equal(26)
    }
    
    func configureLabelStack() {
        labelStack.axis = .vertical
        labelStack.distribution = .equalSpacing
        labelStack.alignment = .top
        
        container.addArrangedSubview(labelStack)
        
        configureUserStack()
        
        
        configureMessageLabel()
    }
    
    func configureUserStack(){
        userStack.backgroundColor = .clear
        userStack.alignment = .top
        userStack.spacing = 8
        labelStack.addArrangedSubview(userStack)
        
        configureNameLabel()
        
        userStack.addArrangedSubview(nameLabel)
        
        rankImgView.image = .iconTopOne
        userStack.addArrangedSubview(rankImgView)
        rankImgView.anchors.width.equal(38)
        rankImgView.anchors.height.equal(14)
    }
    
    func configureNameLabel() {
        nameLabel.font = .roboto(.medium, size: 13)
        nameLabel.numberOfLines = 1
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColor.white.withAlphaComponent(0.68)
        nameLabel.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        nameLabel.layer.shadowRadius = 1
        nameLabel.layer.shadowOpacity = 1
        nameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        nameLabel.layer.masksToBounds = false 
    }
    
    func configureMessageLabel() {
        messageLabel.font = .roboto(.medium, size: 14)
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        messageLabel.textColor = .white
        messageLabel.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        messageLabel.layer.shadowRadius = 2
        messageLabel.layer.shadowOpacity = 1
        messageLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        messageLabel.layer.masksToBounds = false
        
        labelStack.addArrangedSubview(messageLabel)
    }
}
