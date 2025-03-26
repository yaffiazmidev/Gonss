//
//  BaseControlButton.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import SnapKit

typealias ButtonActionBlock = (_ sender: UIButton) -> Void

class BaseControlButton: UIView {
    
    var buttonActionBlock: ButtonActionBlock?
    var imageSize: CGSize
    var spacing: CGFloat
    
    let titleLabel: UILabel = {
        let titleLable = UILabel(frame: CGRect.zero)
        titleLable.font = UIFont.systemFont(ofSize: 12.0)
        titleLable.textAlignment = .center
        return titleLable
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    static func create(frame: CGRect, title: String, imageSize: CGSize, spacing: CGFloat = -10, buttonAction: @escaping ButtonActionBlock) -> BaseControlButton {
        let controlButton = BaseControlButton(frame: frame, imageSize: imageSize, spacing: spacing)
        controlButton.titleLabel.text = title
        controlButton.buttonActionBlock = buttonAction
        return controlButton
    }
    
    init(frame: CGRect, imageSize: CGSize, spacing: CGFloat = -10) {
        self.imageSize = imageSize
        self.spacing = spacing
        super.init(frame: frame)
        backgroundColor = UIColor.clear
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
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(button)
        if !(titleLabel.text?.isEmpty ?? true) {
            addSubview(titleLabel)
        }
    }
    
    func activateConstraints() {
        
        if !(titleLabel.text?.isEmpty ?? true) {
            titleLabel.snp.makeConstraints { make in
                make.leading.trailing.centerX.bottom.equalTo(self)
            }
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.size.equalTo(imageSize)
            if !(titleLabel.text?.isEmpty ?? true) {
                make.bottom.equalTo(titleLabel.snp.top).offset(spacing)
            }
        }
    }
    
    func bindInteraction() {
        button.addTarget(self, action: #selector(buttonActionEvent(sender: )), for: .touchUpInside)
    }
    
    // MARK: Update Info
    func updateImage(image: UIImage) {
        button.setBackgroundImage(image, for: .normal)
    }
    
    func updateTitleColor(titleColor: UIColor) {
        titleLabel.textColor = titleColor
    }
    
    //MARK: Event Action
    @objc func buttonActionEvent(sender: UIButton) {
        guard let buttonActionBlock = buttonActionBlock else { return }
        buttonActionBlock(sender)
    }
}


