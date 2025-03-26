//
//  AnotherUserProfileOptionsViewController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit
import KipasKipasShared

protocol AnotherUserProfileOptionsDelegate: AnyObject {
    func didReport(accountId: String, profile: Profile)
    func didBlock(accountId: String, profile: Profile)
    func didMessage(accountId: String, profile: Profile)
}

class AnotherUserProfileOptionsViewController: CustomHalfViewController {
    private let mainView: AnotherUserProfileOptionsView
    private let accountId: String
    private let profile: Profile
    weak var delegate: AnotherUserProfileOptionsDelegate?
    
    init(accountId: String, profile: Profile) {
        mainView = AnotherUserProfileOptionsView(frame: UIScreen.main.bounds)
        self.accountId = accountId
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        viewHeight = 190
        canSlideUp = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(mainView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blockGesture = UITapGestureRecognizer(target: self, action: #selector(handleBlock(_:)))
        mainView.blockView.addGestureRecognizer(blockGesture)
        
        let reportGesture = UITapGestureRecognizer(target: self, action: #selector(handleReport(_:)))
        mainView.reportView.addGestureRecognizer(reportGesture)
        
        let messageGesture = UITapGestureRecognizer(target: self, action: #selector(handleMessage(_:)))
        mainView.messageView.addGestureRecognizer(messageGesture)
        
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(handleCancel(_:)))
        mainView.cancelView.addGestureRecognizer(cancelGesture)
    }
    
    @objc func handleBlock(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        delegate?.didBlock(accountId: accountId, profile: profile)
    }
    
    @objc func handleReport(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        delegate?.didReport(accountId: accountId, profile: profile)
    }
    
    @objc func handleMessage(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        delegate?.didMessage(accountId: accountId, profile: profile)
    }
    
    @objc func handleCancel(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}
