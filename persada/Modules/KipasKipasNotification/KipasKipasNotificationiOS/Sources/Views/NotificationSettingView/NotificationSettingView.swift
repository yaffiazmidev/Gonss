//
//  NotificationSettingView.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 02/05/24.
//

import UIKit
import KipasKipasNotification

protocol NotificationSettingViewDelegate: AnyObject {
    func didSelectedNotif(by item: NotificationSettingView.NotificationSetting, isOn: Bool)
    func didClose()
}

class NotificationSettingView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeContainerStackView: UIStackView!
    @IBOutlet weak var allNotifSwitch: UISwitch!
    @IBOutlet weak var newFollowersNotifSwitch: UISwitch!
    @IBOutlet weak var likeNotifSwitch: UISwitch!
    @IBOutlet weak var commentNotifSwitch: UISwitch!
    @IBOutlet weak var mentionNotifSwitch: UISwitch!
    
    enum NotificationSetting: Int {
        case allNotifSwitch
        case newFollowersNotifSwitch
        case likeNotifSwitch
        case commentNotifSwitch
        case mentionNotifSwitch
    }
    
    weak var delegate: NotificationSettingViewDelegate?
    
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
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        allNotifSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        newFollowersNotifSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        likeNotifSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        commentNotifSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        mentionNotifSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        let onTapCloseIconGesture = UITapGestureRecognizer(target: self, action: #selector(handleOnTapCloseIcon))
        closeContainerStackView.isUserInteractionEnabled = true
        closeContainerStackView.addGestureRecognizer(onTapCloseIconGesture)
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch) {
        guard let item = NotificationSetting(rawValue: sender.tag) else { return }
        delegate?.didSelectedNotif(by: item, isOn: sender.isOn)
    }
    
    @objc func handleOnTapCloseIcon() {
        delegate?.didClose()
    }
}

extension NotificationSettingView {
    func configureSwitchs(with item: NotificationPreferencesItem) {
        guard !item.allTrue else {
            setAllNotifSwitch(isOn: true)
            return
        }
        
        newFollowersNotifSwitch.isOn = item.socialMediaFollower
        likeNotifSwitch.isOn = item.socialMediaLike
        commentNotifSwitch.isOn = item.socialMediaComment
        mentionNotifSwitch.isOn = item.socialMediaMention
    }
    
    func setAllNotifSwitch(isOn: Bool) {
        allNotifSwitch.isOn = isOn
        newFollowersNotifSwitch.isOn = isOn
        likeNotifSwitch.isOn = isOn
        commentNotifSwitch.isOn = isOn
        mentionNotifSwitch.isOn = isOn
    }
}
