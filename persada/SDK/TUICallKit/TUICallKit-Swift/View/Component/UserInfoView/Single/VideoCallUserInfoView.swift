//
//  VideoCallUserInfoView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class VideoCallUserInfoView: UIView {
    
    let viewModel = UserInfoViewModel()
    let selfCallStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 50
        if let image = TUICallKitCommon.getBundleImage(name: "userIcon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        userNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    let waitingInviteLabel: UILabel = {
        let waitingInviteLabel = UILabel(frame: CGRect.zero)
        waitingInviteLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        waitingInviteLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        waitingInviteLabel.backgroundColor = UIColor.clear
        waitingInviteLabel.textAlignment = .center
        return waitingInviteLabel
    }()
    
    lazy var mainStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [userHeadImageView, userNameLabel, waitingInviteLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 8
        view.alignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateWaitingText()
        setUserImageAndName()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.remoteUserList.removeObserver(remoteUserListObserver)
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(mainStackView)
//        addSubview(userHeadImageView)
//        addSubview(userNameLabel)
//        addSubview(waitingInviteLabel)
    }
    
    func activateConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
        }
        
        self.userHeadImageView.snp.makeConstraints { make in
//            make.top.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
//        self.userHeadImageView.snp.makeConstraints { make in
//            make.top.equalTo(self)
//            make.trailing.equalTo(self)
//            make.size.equalTo(CGSize(width: 100, height: 100))
//        }
//        
//        self.userNameLabel.snp.makeConstraints { make in
//            make.top.equalTo(userHeadImageView.snp.top).offset(20)
//            make.trailing.equalTo(userHeadImageView.snp.leading).offset(-20)
//        }
//        
//        self.waitingInviteLabel.snp.makeConstraints { make in
//            make.top.equalTo(userHeadImageView.snp.top).offset(60)
//            make.trailing.equalTo(userHeadImageView.snp.leading).offset(-20)
//        }
    }

    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChange()
        remmoteUserListChanged()
    }
    
    func callStatusChange() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateWaitingText()
        })
    }
    
    func remmoteUserListChanged() {
        viewModel.remoteUserList.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setUserImageAndName()
        })
    }

    // MARK: Update UI
    func setUserImageAndName() {
        let remoteUser = viewModel.remoteUserList.value.first ?? User()
        userNameLabel.text = User.getUserDisplayName(user: remoteUser)
        
        if let url = URL(string: remoteUser.avatar.value) {
            userHeadImageView.sd_setImage(with: url)
        }
    }

    func updateWaitingText() {
        switch viewModel.selfCallStatus.value {
            case .waiting:
                self.waitingInviteLabel.text =  viewModel.getCurrentWaitingText()
                break
            case .accept:
                self.waitingInviteLabel.text = ""
                self.waitingInviteLabel.isHidden = true
                break
            case .none:
                break
            default:
                break
        }
    }
}
