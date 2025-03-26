//
//  VideoCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import SnapKit

class VideoCallerAndCalleeAcceptedView: UIView {
    
    let viewModel = VideoCallerAndCalleeAcceptedViewModel()
    lazy var muteMicBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(
            frame: CGRect.zero,
            title: "",
            imageSize: .init(width: 48, height: 48)
        ) { sender in
            weakSelf?.muteMicEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "ic_mute") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return btn
    }()
    
    lazy var closeCameraBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(
            frame: CGRect.zero,
            title: "",
            imageSize: .init(width: 48, height: 48)
        ) { sender in
            weakSelf?.closeCameraTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "camera_on") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return btn
    }()
    
    lazy var changeSpeakerBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(
            frame: CGRect.zero,
            title: "",
            imageSize: .init(width: 48, height: 48)
        ) { sender in
            weakSelf?.changeSpeakerEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "ic_handsfree_on") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return btn
    }()
    
    lazy var hangupBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(
            frame: CGRect.zero,
            title: "Tutup",
            imageSize: .init(width: 56, height: 56)
        ) { sender in
            weakSelf?.hangupTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "ic_hangup") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return btn
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        addSubview(muteMicBtn)
        addSubview(changeSpeakerBtn)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        addSubview(switchCameraBtn)
    }

    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
//            make.trailing.equalTo(changeSpeakerBtn.snp.leading)
            make.trailing.equalTo(changeSpeakerBtn.snp.leading).offset(-48)
            make.centerY.equalTo(changeSpeakerBtn)
//            make.size.equalTo(kControlBtnSize)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
//            make.bottom.equalTo(hangupBtn.snp.top).offset(-10)
            make.bottom.equalTo(hangupBtn.snp.top).offset(-30)
//            make.size.equalTo(kControlBtnSize)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        closeCameraBtn.snp.makeConstraints { make in
//            make.leading.equalTo(changeSpeakerBtn.snp.trailing)
            make.leading.equalTo(changeSpeakerBtn.snp.trailing).offset(48)
            make.centerY.equalTo(changeSpeakerBtn)
//            make.size.equalTo(kControlBtnSize)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
//            make.bottom.equalTo(snp.bottom)
//            make.size.equalTo(kControlBtnSize)
            make.bottom.equalTo(self.snp.bottom)
            make.width.equalTo(56)
            make.height.equalTo(80)
        }
        
        switchCameraBtn.snp.makeConstraints { make in
//            make.centerY.equalTo(hangupBtn)
//            make.leading.equalTo(hangupBtn.snp.trailing).offset(20)
//            make.size.equalTo(CGSize(width: 36, height: 36))
            make.leading.equalTo(self.hangupBtn.snp.trailing).offset(48)
            make.top.equalTo(self.hangupBtn.snp.top).offset(5)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }

    //MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        viewModel.muteMic()
        updateMuteAudioBtn(mute: viewModel.isMicMute.value == true)
    }

    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: viewModel.isCameraOpen.value != true)
        if viewModel.isCameraOpen.value == true {
            viewModel.closeCamera()
        } else {
            guard let videoViewEntity = VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] else { return }
            viewModel.openCamera(videoView: videoViewEntity.videoView)
        }
    }

    func changeSpeakerEvent(sender: UIButton) {
        viewModel.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: viewModel.audioDevice.value == .speakerphone)
    }

    func hangupTouchEvent(sender: UIButton) {
        viewModel.hangup()
    }

    @objc func switchCameraTouchEvent(sender: UIButton) {
        viewModel.switchCamera()
    }
    
    //MARK: Update UI
    func updateMuteAudioBtn(mute: Bool) {
        if let image = TUICallKitCommon.getBundleImage(name: mute ? "ic_mute_on" : "ic_mute") {
            muteMicBtn.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        if let image = TUICallKitCommon.getBundleImage(name: isSpeaker ? "ic_handsfree_on" : "ic_handsfree") {
            changeSpeakerBtn.updateImage(image: image)
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        if let image = TUICallKitCommon.getBundleImage(name: open ? "camera_on" : "camera_off") {
            closeCameraBtn.updateImage(image: image)
        }
    }
}
