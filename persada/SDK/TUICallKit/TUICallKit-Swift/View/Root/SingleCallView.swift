//
//  SingleCallView.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//
import SnapKit

class SingleCallView: UIView {
    
    let viewModel: SingleCallViewModel = SingleCallViewModel()
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    private var isViewReady: Bool = false
    private var userId: String = ""
    
    let userInfoAudioView = {
        return AudioCallUserInfoView(frame: CGRect.zero)
    }()
    
    let userInfoVideoView = {
        return VideoCallUserInfoView(frame: CGRect.zero)
    }()
    
    let audioFunctionView = {
        return AudioCallerWaitingAndAcceptedView(frame: CGRect.zero)
    }()
    
    let videoFunctionView =  {
        return VideoCallerAndCalleeAcceptedView(frame: CGRect.zero)
    }()
    
    let videoInviteFunctionView = {
        return VideoCallerWaitingView(frame: CGRect.zero)
    }()
    
    let inviteeWaitFunctionView = {
        return AudioAndVideoCalleeWaitingView(frame: CGRect.zero)
    }()
    
    let renderBackgroundView = {
        return SingleCallVideoLayout(frame: CGRect.zero)
    }()
    
    let switchToAudioView = {
        return SwitchAudioView(frame: CGRect.zero)
    }()
    
    let timerView = {
        return TimerView(frame: CGRect.zero)
    }()
    
    let floatingWindowBtn = {
        return FloatingWindowButton(frame: CGRect.zero)
    }()
    
    lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Panggilan ini sedang di mute"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.isHidden = true
        return label
    }()

    private lazy var videoActionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [switchToAudioView, videoInviteFunctionView, videoFunctionView, inviteeWaitFunctionView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 30
        view.alignment = .center
        return view
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        let screenSize = UIScreen.main.bounds.size
        self.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        backgroundColor = UIColor.t_colorWithHexString(color: "#EEEEEE")
        
        createView()
        registerObserveState()
        getUserId()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.mediaType.removeObserver(mediaTypeObserver)
        viewModel.remoteUserList.removeObserver(remoteUserListObserver)
        
        for view in subviews {
            view.removeFromSuperview()
        }
    }
    
    //MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(renderBackgroundView)
        addSubview(userInfoAudioView)
        addSubview(userInfoVideoView)
        addSubview(audioFunctionView)
//        addSubview(videoFunctionView)
//        addSubview(videoInviteFunctionView)
        addSubview(videoActionView)
//        addSubview(inviteeWaitView)
//        addSubview(inviteeWaitFunctionView)
//        addSubview(switchToAudioView)
        addSubview(timerView)
        addSubview(muteLabel)
        addSubview(floatingWindowBtn)
        
    }
    
    func activateConstraints() {
        let isAudioCall: Bool = TUICallState.instance.mediaType.value == .audio ? true : false

        renderBackgroundView.snp.makeConstraints { make in
            make.size.equalTo(self)
        }
        
        userInfoAudioView.snp.makeConstraints { make in
//            make.top.equalTo(self).offset(StatusBar_Height + 75.0)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalTo(self)
//            make.width.equalTo(self)
//            make.height.equalTo(200)
        }
        
        userInfoVideoView.snp.makeConstraints { make in
//            make.top.equalTo(self).offset(StatusBar_Height + 20.0)
//            make.leading.equalTo(self).offset(20)
//            make.trailing.equalTo(self).offset(-20)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(80)
            make.centerX.equalTo(self)
        }

        audioFunctionView.snp.makeConstraints({ make in
            make.centerX.equalTo(self)
//            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
//            make.height.equalTo(92.0)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-48)
            make.height.equalTo(80)
            make.width.equalTo(self.snp.width)
        })
        
        videoFunctionView.snp.makeConstraints({ make in
//            make.centerX.equalTo(self)
//            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
//            make.height.equalTo(200.0)
            make.height.equalTo(158)
            make.width.equalTo(self.snp.width)
        })

        videoInviteFunctionView.snp.makeConstraints({ make in
//            make.centerX.equalTo(self)
//            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
//            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-48)
//            make.height.equalTo(92.0)
            make.height.equalTo(80)
            make.width.equalTo(self.snp.width)
        })
        
        switchToAudioView.snp.makeConstraints { make in
//            make.centerX.equalTo(self)
            make.height.equalTo(60)
            make.width.equalTo(self.snp.width)
//            make.bottom.equalTo(self.videoFunctionView.snp.top).offset(-10)
        }
        
        videoActionView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.width.equalTo(self.snp.width)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-48)
        }

        inviteeWaitFunctionView.snp.makeConstraints({ make in
//            make.centerX.equalTo(self)
//            make.bottom.equalTo(self.snp.top).offset(self.frame.size.height - Bottom_SafeHeight - 20)
//            make.height.equalTo(92.0)
//            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-48)
            make.height.equalTo(80)
            make.width.equalTo(self.snp.width)
        })

        timerView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
//            make.height.equalTo(30)
//            make.width.equalTo(snp.width)
//            make.bottom.equalTo(isAuidoCall ? self.audioFunctionView.snp.top : self.switchToAudioView.snp.top).offset(-10)
            if !isAudioCall {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
            } 
        }

        muteLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
//            make.height.equalTo(30)
//            make.width.equalTo(snp.width)
//            make.bottom.equalTo(isAuidoCall ? self.audioFunctionView.snp.top : self.switchToAudioView.snp.top).offset(-10)
            if !isAudioCall {
                make.top.equalTo(self.timerView.snp.bottom).offset(8)
            }
        }

        floatingWindowBtn.snp.makeConstraints { make in
            make.size.equalTo(kFloatWindowButtonSize)
            make.top.equalToSuperview().offset(StatusBar_Height + 10)
            make.leading.equalToSuperview().offset(20)
        }
    }
    
    //MARK: View Create & Manage
    func createView() {
        cleanView()
        
        if viewModel.enableFloatWindow {
            floatingWindowBtn.isHidden = false
        } else {
            floatingWindowBtn.isHidden = true
        }
        
        if viewModel.selfCallStatus.value == .waiting {
            createWaitingView()
        } else if viewModel.selfCallStatus.value == .accept {
            createAcctepView()
        }
        
        updateMuteLabel(from: viewModel.remoteUserList.value)
    }
    
    func createWaitingView() {
        switch TUICallState.instance.mediaType.value {
            case .audio:
                createAudioWaitingView()
            case .video:
                createVideoWaitingView()
            case .unknown:
                break
            default:
                break
        }
    }
    
    func createAudioWaitingView() {
        userInfoAudioView.isHidden = false
        muteLabel.isHidden = true
        if viewModel.selfCallRole.value == .call {
            audioFunctionView.isHidden = false
            audioFunctionView.changeSpeakerBtn.isHidden = true
            audioFunctionView.muteMicBtn.isHidden = true
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createVideoWaitingView() {
        renderBackgroundView.isHidden = false
        muteLabel.isHidden = true
        userInfoVideoView.isHidden = false
        switchToAudioView.isHidden = false
        if viewModel.selfCallRole.value == .call {
            videoInviteFunctionView.isHidden = false
        } else {
            inviteeWaitFunctionView.isHidden = false
        }
    }
    
    func createAcctepView() {
        switch viewModel.mediaType.value {
            case .audio:
                createAudioAcceptView()
            case .video:
                createVideoAcceptView()
            case .unknown:
                break
            default:
                break
        }
    }
    
    func createAudioAcceptView() {
        userInfoAudioView.isHidden = false
        timerView.isHidden = false
        audioFunctionView.isHidden = false
        audioFunctionView.changeSpeakerBtn.isHidden = false
        audioFunctionView.muteMicBtn.isHidden = false
        
        timerView.removeFromSuperview()
        muteLabel.removeFromSuperview()
        userInfoAudioView.mainStackView.addArrangedSubview(timerView)
        userInfoAudioView.mainStackView.addArrangedSubview(muteLabel)
        timerView.timerLabel.textColor = .black
        timerView.timerLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        muteLabel.textColor = .black
    }
    
    func createVideoAcceptView() {
        renderBackgroundView.isHidden = false
        timerView.isHidden = false
        switchToAudioView.isHidden = false
        videoFunctionView.isHidden = false
        muteLabel.textColor = .white
    }

    func cleanView() {
        userInfoVideoView.isHidden = true
        userInfoAudioView.isHidden = true
        audioFunctionView.isHidden = true
        videoFunctionView.isHidden = true
        videoInviteFunctionView.isHidden = true
        inviteeWaitFunctionView.isHidden = true
        renderBackgroundView.isHidden = true
        timerView.isHidden = true
        muteLabel.isHidden = true
        switchToAudioView.isHidden = true
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChanged()
        mediaTypeChanged()
        remoteUserListChanged()
    }
    
    func callStatusChanged() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createView()
        })
    }
    
    func mediaTypeChanged() {
        viewModel.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            self.createView()
        }
    }
    
    func remoteUserListChanged() {
        viewModel.remoteUserList.addObserver(remoteUserListObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.createView()
            self.updateMuteLabel(from: newValue)
        }
    }
    
    func getUserId() {
        User.getSelfUserInfo { [weak self] user in
            guard let self = self else { return }
            self.userId = user.id.value
        }
    }
    
    func updateMuteLabel(from users: [User]?) {
        guard !userId.isEmpty,
              let audioAvailable = users?.first(where: {$0.id.value != userId})?.audioAvailable.value
        else { return }
        
        muteLabel.isHidden = audioAvailable
    }
}
