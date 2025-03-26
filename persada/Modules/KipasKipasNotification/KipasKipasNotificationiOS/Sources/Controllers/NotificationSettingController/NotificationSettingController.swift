//
//  NotificationSettingController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 02/05/24.
//

import UIKit
import KipasKipasShared
import KipasKipasNotification

class NotificationSettingController: CustomHalfViewController {

    let mainView: NotificationSettingView
    let viewModel: INotificationSettingViewModel
    
    private var preferences: NotificationPreferencesItem = NotificationPreferencesItem()
    
    init(viewModel: INotificationSettingViewModel) {
        self.viewModel = viewModel
        mainView = NotificationSettingView()
        super.init(nibName: nil, bundle: nil)
        mainView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        overrideUserInterfaceStyle = .light
        canSlideUp = false
        viewHeight = 560
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchPreferences()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(mainView)
        mainView.anchors.leading.equal(containerView.anchors.leading)
        mainView.anchors.trailing.equal(containerView.anchors.trailing)
        mainView.anchors.top.equal(containerView.anchors.top)
        mainView.anchors.bottom.equal(containerView.safeAreaLayoutGuide.anchors.bottom)
    }
}


extension NotificationSettingController: NotificationSettingViewDelegate {
    func didSelectedNotif(by item: NotificationSettingView.NotificationSetting, isOn: Bool) {
        switch item {
        case .allNotifSwitch:
            mainView.setAllNotifSwitch(isOn: isOn)
            preferences.setAll(isOn: isOn)
        case .newFollowersNotifSwitch:
            preferences.socialMediaFollower = isOn
        case .likeNotifSwitch:
            preferences.socialMediaLike = isOn
        case .commentNotifSwitch:
            preferences.socialMediaComment = isOn
        case .mentionNotifSwitch:
            preferences.socialMediaMention = isOn
        }
        
        viewModel.updatePreferences(by: preferences)
    }
    
    func didClose() {
        animateDismissView()
    }
}

extension NotificationSettingController: NotificationSettingViewModelDelegate {
    func displayPreferences(with item: NotificationPreferencesItem) {
        preferences = item
        mainView.configureSwitchs(with: item)
    }
    
    func displayError(with message: String) {
        print(message)
    }
}
