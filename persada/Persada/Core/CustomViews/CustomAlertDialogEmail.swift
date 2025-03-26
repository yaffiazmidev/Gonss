//
//  CustomAlertDialogEmail.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 25/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CustomAlertDialogEmail : UIViewController {

    
    var onCancel : (() -> Void)?
    var onConfirm : (() -> Void)?

    
    var dialogTitle : String?
    var dialogDescription : String?
    var buttonNegativeText : String?
    var buttonPositiveText : String?
    let disposeBag = DisposeBag()
    
    let background : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 0
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.grey.cgColor
        return view
    }()
    let alertTitle : UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
        return label
    }()
    
    let alertDescription : UILabel = {
        let label = UILabel(font: .Roboto(.medium, size: 12), textColor: .contentGrey, textAlignment: .left, numberOfLines: 0)
        return label
    }()
    
    let buttonPositive : UIButton = {
        let button = UIButton()
        button.titleLabel?.font =  .Roboto(.medium, size: 12)
        button.setTitleColor(.systemBlue, for: .normal)
        return button
    }()
    
    let buttonNegative : UIButton = {
        let button = UIButton()
        button.titleLabel?.font =  .Roboto(.medium, size: 12)
        button.setTitleColor(.placeholder, for: .normal)
        return button
    }()
    
    init(dialogTitle: String? = nil, dialogDescription: String? = nil, buttonNegativeText: String? = nil, buttonPositiveText: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.dialogTitle = dialogTitle
        self.dialogDescription = dialogDescription
        self.buttonNegativeText = buttonNegativeText
        self.buttonPositiveText = buttonPositiveText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        setData()
    }
    
    func setData(){
        alertTitle.text = dialogTitle
        alertDescription.text = dialogDescription
        buttonPositive.setTitle(buttonPositiveText, for: .normal)
        buttonNegative.setTitle(buttonNegativeText, for: .normal)
    }

    
    func initView(){
        view.backgroundColor = .blackTransparent
        view.addSubview(background)
        background.addSubview(alertTitle)
        background.addSubview(alertDescription)
        background.addSubview(buttonPositive)
        background.addSubview(buttonNegative)
        
        let width = view.frame.width - 40
        background.anchor(width: width, height: 160)
        background.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        background.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        alertTitle.anchor(top: background.topAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24)
        alertDescription.anchor(top: alertTitle.bottomAnchor, left: background.leftAnchor, right: background.rightAnchor, paddingTop: 14, paddingLeft: 24, paddingRight: 24)
        buttonPositive.anchor(top: alertDescription.bottomAnchor, bottom: nil, right: background.rightAnchor, paddingTop: 20, paddingLeft: 24, paddingBottom: 24, paddingRight: 24)
        buttonNegative.anchor(top: alertDescription.bottomAnchor, left: nil, bottom: nil, right: buttonPositive.leftAnchor, paddingTop: 20, paddingLeft: 24, paddingBottom: 24, paddingRight: 20)
        
//        buttonPositive.addTarget(self, action: #selector(positiveButtonTapped), for: .touchUpInside)
//        buttonNegative.addTarget(self, action: #selector(negativeButtonTapped), for: .touchUpInside)
        buttonPositive.rx.tap.subscribe { (_) in
            self.positiveButtonTapped()
        }.disposed(by: disposeBag)
        
        buttonNegative.rx.tap.subscribe { (_) in
            self.negativeButtonTapped()
        }.disposed(by: disposeBag)
    }

    func positiveButtonTapped(){
        confirmationButtonPresssed()
    }
    
    func negativeButtonTapped(){
        cancelButtonPressed()
    }
    
    func cancelButtonPressed() {
        // defered to ensure it is performed no matter what code path is taken
        defer {
            dismiss(animated: false, completion: nil)
        }

        let onCancel = self.onCancel
        // deliberately set to nil just in case there is a self reference
        self.onCancel = nil
        guard let block = onCancel else { return }
        block()
    }

    func confirmationButtonPresssed() {
        // defered to ensure it is performed no matter what code path is taken
        defer {
            dismiss(animated: false, completion: nil)
        }
        let onConfirm = self.onConfirm
        // deliberately set to nil just in case there is a self reference
        self.onConfirm = nil
        guard let block = onConfirm else { return }
        block()
    }
}


class AlertDialogCustom {
    static let instance = AlertDialogCustom()
    
    func createAlertDialog(dialogTitle: String, dialogDescription: String, buttonNegativeText: String, buttonPositiveText: String) -> CustomAlertDialogEmail {
        
        let cutomAlertDialog = CustomAlertDialogEmail(dialogTitle: dialogTitle, dialogDescription: dialogDescription, buttonNegativeText: buttonNegativeText, buttonPositiveText: buttonPositiveText)
        cutomAlertDialog.modalPresentationStyle = .overCurrentContext
        cutomAlertDialog.isModalInPresentation = true
        
        return cutomAlertDialog
    }
}
