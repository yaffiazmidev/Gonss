//
//  NotificationSettingViewModel.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 03/05/24.
//

import Foundation
import KipasKipasNotification


protocol INotificationSettingViewModel {
    func fetchPreferences()
    func updatePreferences(by item: NotificationPreferencesItem)
}

protocol NotificationSettingViewModelDelegate: AnyObject {
    func displayPreferences(with item: NotificationPreferencesItem)
    func displayError(with message: String)
}

class NotificationSettingViewModel: INotificationSettingViewModel {
    
    public weak var delegate: NotificationSettingViewModelDelegate?
    private let preferencesLoader: NotificationPreferencesLoader
    private let preferencesUpdater: NotificationPreferencesUpdater
    
    init(
        preferencesLoader: NotificationPreferencesLoader,
        preferencesUpdater: NotificationPreferencesUpdater
    ) {
        self.preferencesLoader = preferencesLoader
        self.preferencesUpdater = preferencesUpdater
    }
    
    func fetchPreferences() {
        let request = NotificationPreferencesRequest(code: "push")
        preferencesLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(let response):
                self.delegate?.displayPreferences(with: response)
            }
        }
    }
    
    func updatePreferences(by item: NotificationPreferencesItem) {
        let request = NotificationPreferencesUpdateRequest(
            code: "push",
            subCodes: SubCodes(
                socialmedia: item.socialmedia,
                socialMediaComment: item.socialMediaComment,
                socialMediaLike: item.socialMediaLike,
                socialMediaMention: item.socialMediaMention,
                socialMediaFollower: item.socialMediaFollower,
                socialMediaLive: item.socialMediaLive,
                socialMediaAccount: item.socialMediaAccount
            )
        )
        preferencesUpdater.update(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                self.delegate?.displayError(with: error.localizedDescription)
            case .success(_):
                print("Success update preferences..")
            }
        }
    }
}
