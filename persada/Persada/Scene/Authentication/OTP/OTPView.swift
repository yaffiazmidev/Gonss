//
//  OTPView.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit

protocol OTPViewDelegate where Self: UIViewController {
    func textNumber() -> String
    func handleBackButton()
}

final class OTPView: UIView {
    
    weak var delegate: OTPViewDelegate?
    
    private enum ViewTrait {
        static let leftMargin: CGFloat = 10.0
        static let bgImageAlpha: CGFloat = 0.6
        static let bgImageHeight: CGFloat = UIScreen.main.bounds.height * 0.30
    }
        
    lazy var backgroundImageView: UIView = {
        let view: UIView = UIView()
        
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.alpha = ViewTrait.bgImageAlpha
        overlayView.backgroundColor = .black
        
        let imageView = UIImageView(image: UIImage(named: "registerBG"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        view.addSubview(overlayView)
        
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: ViewTrait.bgImageHeight)
        overlayView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: ViewTrait.bgImageHeight)
        return view
    }()
    
    lazy var titleVerificationLabel: UILabel = {
        let label = UILabel(text: "Verifikasi Nomor", font: .systemFont(ofSize: 20, weight: .bold), textColor: .white, textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    lazy var otpItemsView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .white
        view.setupShadow(opacity: 1, radius: 16, offset: CGSize(width: 2, height: 4), color: UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.1))
        view.layer.cornerRadius = 16
        
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button: UIButton = UIButton()
        let image = UIImage(named: "arrowleft")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(self.handleBackButton), for: .touchUpInside)
        return button
    }()
    
    lazy var subTextOTPLabel: UILabel = {
        let label = UILabel(text: "Masukan kode yang telah kami kirimkan ke", font: .systemFont(ofSize: 12, weight: .regular), textColor: UIColor(hexString: "#4A4A4A"), textAlignment: .center, numberOfLines: 1)
        return label
    }()
    
    lazy var textNumberLabel: UILabel = {
        let label = UILabel(text: "", font: .boldSystemFont(ofSize: 14), textColor: UIColor(hexString: "#4A4A4A"), textAlignment: .center, numberOfLines: 1)
        return label
    }()
    
    lazy var errorLabel: UILabel = {
        let label = UILabel(text: "", font: UIFont.Roboto(.medium, size: 12), textColor: UIColor(hexString: "#E70000"), textAlignment: .center, numberOfLines: 2)
        label.isHidden = true
        return label
    }()
    
    let otpView: SVPinView = {
        let pinView = SVPinView()
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinView.pinLength = 4
        pinView.secureCharacter = "\u{25CF}"
        pinView.interSpace = 15
        pinView.textColor = UIColor.gray
        pinView.borderLineColor = .init(hexString: "#EEEEEE")
        pinView.activeBorderLineColor = .black
        pinView.activeBorderLineThickness = 3
        pinView.borderLineThickness = 3
        pinView.shouldSecureText = false
        pinView.allowsWhitespaces = false
        pinView.style = .underline
        pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
        pinView.activeFieldBackgroundColor = .white
        pinView.fieldCornerRadius = 15
        pinView.activeFieldCornerRadius = 15
        pinView.becomeFirstResponderAtIndex = 0
        pinView.shouldDismissKeyboardOnEmptyFirstField = false
			pinView.font = .Roboto(.medium, size: 15)
        pinView.keyboardType = .phonePad
        return pinView
    }()
    
    let notReceivedOTPLabel = UILabel(text: "Tidak menerima kode verifikasi?", font: .Roboto(size: 12), textColor: .grey, textAlignment: .center, numberOfLines: 1)
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .primary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .Roboto(.medium, size: 14)
        return label
    }()
    
    lazy var changeOTPOptionLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = false
        label.textColor = .grey
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .Roboto(size: 12)
        let attributedText = NSMutableAttributedString(string: "atau ")
        
        let attrString = NSAttributedString(
            string: "Ubah metode pengiriman OTP",
            attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                         NSAttributedString.Key.foregroundColor: UIColor.secondary,
                         NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 12)]
        )
        attributedText.append(attrString)
        label.attributedText = attributedText
        return label
    }()
        
    override func draw(_ rect: CGRect) {
        
        self.addSubview(backgroundImageView)
        self.addSubview(backButton)
        self.addSubview(titleVerificationLabel)
        self.addSubview(otpItemsView)
        
        self.otpItemsView.addSubview(subTextOTPLabel)
        self.otpItemsView.addSubview(textNumberLabel)
        self.otpItemsView.addSubview(otpView)
        self.otpItemsView.addSubview(errorLabel)
        
        self.addSubview(notReceivedOTPLabel)
        self.addSubview(timerLabel)
        self.addSubview(changeOTPOptionLabel)
        
        backgroundImageView.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: ViewTrait.bgImageHeight)
        
        backButton.anchor(top: self.safeAreaLayoutGuide.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 22, paddingBottom: 0, paddingRight: 0)
        
        titleVerificationLabel.anchor(top: backButton.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 28, paddingLeft: 32, paddingBottom: 0, paddingRight: 0)
        
        otpItemsView.anchor(top: titleVerificationLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 36, paddingLeft: 32, paddingBottom: 0, paddingRight: 32)
        
        subTextOTPLabel.anchor(top: otpItemsView.topAnchor, left: otpItemsView.leftAnchor, bottom: nil, right: otpItemsView.rightAnchor, paddingTop: 32, paddingLeft: 23, paddingBottom: 0, paddingRight: 23)
        
        textNumberLabel.anchor(top: subTextOTPLabel.bottomAnchor, left: otpItemsView.leftAnchor, bottom: nil, right: otpItemsView.rightAnchor, paddingTop: 4, paddingLeft: 23, paddingBottom: 0, paddingRight: 23)
        
        otpView.anchor(top: textNumberLabel .bottomAnchor, left: otpItemsView.leftAnchor, bottom: otpItemsView.bottomAnchor, right: otpItemsView.rightAnchor, paddingTop: 36, paddingLeft: 56, paddingBottom: 40, paddingRight: 56)
        
        errorLabel.anchor(top: otpView.bottomAnchor, left: otpItemsView.leftAnchor, right: otpItemsView.rightAnchor, paddingTop: 0, paddingLeft: 16, paddingRight: 16)
        
        notReceivedOTPLabel.anchor(top: otpItemsView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 36, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        timerLabel.anchor(top: notReceivedOTPLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        changeOTPOptionLabel.anchor(top: timerLabel.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 24, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    func showError(message: String) {
        errorLabel.isHidden = false
        errorLabel.text = message
    }
    
    func hideError() {
        errorLabel.isHidden = true
        errorLabel.text = nil
    }
    
    func reloadNumberText() {
        self.textNumberLabel.text = delegate?.textNumber()
    }
    
    @objc private func handleBackButton() {
        delegate?.handleBackButton()
    }
}
