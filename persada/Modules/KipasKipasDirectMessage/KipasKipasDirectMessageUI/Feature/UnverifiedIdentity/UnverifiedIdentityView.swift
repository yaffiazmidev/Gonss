//
//  UnverifiedIdentityView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 14/06/24.
//

import UIKit
import KipasKipasShared

class UnverifiedIdentityView: UIView {

    @IBOutlet weak var containerView: UIView!
    
    public var handleContinueVerificationButton: ((String) -> Void)?
    public var handleVerificationLaterButton: (() -> Void)?
    
    public var verifyStatus: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        addSubview(containerView)
        containerView.anchors.edges.pin()
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        containerView.backgroundColor = .white
    }
    
    @IBAction func didClickContinueVerificationButton(_ sender: Any) {
        handleContinueVerificationButton?(verifyStatus)
    }
    
    @IBAction func didClickVerificationLaterButton(_ sender: Any) {
        handleVerificationLaterButton?()
    }
}
