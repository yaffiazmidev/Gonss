//
//  CallViewController.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import KipasKipasCall
import Kingfisher

protocol CallViewControllerDelegate {
    func didUserLoginData(data: CallProfile)
    func didCall(target: CallProfile, type: CallType)
    func didLogout()
}

class CallViewController: UIViewController {
    private let mainView: CallView
    
    var delegate: CallViewControllerDelegate?
    var profileDelegate: ProfileDelegate?
    
    private var userLogin: CallProfile?
    private var targetUser: CallProfile?
    
    init() {
        mainView = CallView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupOnTap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserData()
    }
}

private extension CallViewController {
    func getUserData() {
        if let user = LoggedUserKeychainStore().retrieve() {
            profileDelegate?.didProfileData(userId: user.accountId) { [weak self] (profile, message) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.userLogin = profile
                    self.setupUserLoginView()
                    
                    if let message = message {
                        self.showToast(with: message)
                    }
                    
                    if let profile = profile {
                        self.delegate?.didUserLoginData(data: profile)
                    }
                }
            }
        }
    }
    
    func setupView() {
        setupUserLoginView()
        setupUserTargetView()
    }
    
    func setupUserLoginView() {
        DispatchQueue.main.async {
            self.mainView.userLoginView.isHidden = self.userLogin == nil
            
            if let profile = self.userLogin {
                if let photo = profile.photo, let url = URL(string: photo) {
                    self.mainView.userLoginImageView.kf.setImage(with: url)
                }
                
                self.mainView.userLoginFullNameLabel.text = profile.name
                self.mainView.userLoginUserNameLabel.text = profile.username
            }
        }
    }
    
    func setupUserTargetView() {
        DispatchQueue.main.async {
            self.mainView.targetUserView.isHidden = self.targetUser == nil
            self.mainView.targetUserButton.isHidden = self.targetUser != nil
            
            if let profile = self.targetUser {
                if let photo = profile.photo, let url = URL(string: photo) {
                    self.mainView.targetUserImageView.kf.setImage(with: url)
                }
                
                self.mainView.targetUserFullNameLabel.text = profile.name
                self.mainView.targetUserNameLabel.text = profile.username
            }
        }
    }
    
    func setupOnTap() {
        mainView.targetUserView.onTap(action: selectTarget)
        mainView.targetUserButton.onTap(action: selectTarget)
        
        mainView.videoCallButton.onTap {
            guard let target = self.targetUser else {
                self.showToast(with: "Select Target First!")
                return
            }
            
            let title = "KipasKipasCallApp need your permission to access your microphone for video call"
            
            CallPermission.instance.camera { [weak self] granted in
                guard let self = self else { return }
                
                if granted {
                    requestMicrophone(alertTitle: title) {
                        self.delegate?.didCall(target: target, type: .video)
                    }
                    return
                }
                
                self.showAlert(title: "KipasKipasCallApp need your permission to access your camera for video call", access: "Camera") {
                    self.requestMicrophone(alertTitle: title)
                }
            }
        }
        
        mainView.voiceCallButton.onTap {
            guard let target = self.targetUser else {
                self.showToast(with: "Select Target First!")
                return
            }
            
            self.requestMicrophone(alertTitle: "KipasKipasCallApp need your permission to access your microphone for voice call") {
                self.delegate?.didCall(target: target, type: .audio)
            }
        }
        
        mainView.logoutButton.onTap {
            self.delegate?.didLogout()
        }
    }
    
    func selectTarget() {
        let controller = CallSearchUserController()
        controller.modalPresentationStyle = .pageSheet
        controller.delegate = profileDelegate
        controller.didSelectUser = { [weak self] profile in
            guard let self = self, profile.id != userLogin?.id else { return }

            self.targetUser = profile
            self.setupUserTargetView()
        }
        present(controller, animated: true)
    }
    
    func requestMicrophone(alertTitle: String, onGranted: (() -> Void)? = nil) {
        CallPermission.instance.microphone { [weak self] granted in
            guard let self = self else { return }
            
            if granted {
                onGranted?()
                return
            }
            
            self.showAlert(title: alertTitle, access: "Microphone")
        }
    }
    
    func showAlert(title: String, access: String, onCancel: (() -> Void)? = nil) {
        let actionSheet = UIAlertController(title: "", message: title, preferredStyle: .alert)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow \(access) Access", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            onCancel?()
        }
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(actionSheet, animated: true)
        }
    }
}
