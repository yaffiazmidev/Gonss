//
//  FeedBackSenderPresenter.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class FeedBackSenderPresenter {
    private let successView: FeedbackSenderView?
    private let loadingView: FeedbackSenderLoadingView?
    private let errorView: FeedbackSenderErrorView?
    
    init(
        successView: FeedbackSenderView,
        loadingView: FeedbackSenderLoadingView,
        errorView: FeedbackSenderErrorView) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("NOTIFICATION_PREFERENCES_GET_ERROR",
                          tableName: "NotificationPreferences",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    
    func didStartLoadingSendFeedback() {
        errorView?.display(.noError)
        loadingView?.display(FeedbackSenderLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingSendFeedback(with item: FeedbackSenderItem) {
        successView?.display(FeedbackSenderViewModels(item: item))
        loadingView?.display(FeedbackSenderLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingSendFeedback(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(FeedbackSenderLoadingViewModel(isLoading: false))
    }
}
