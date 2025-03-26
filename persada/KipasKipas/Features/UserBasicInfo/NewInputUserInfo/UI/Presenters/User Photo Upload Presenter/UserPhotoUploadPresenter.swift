//
//  UserPhotoUploadPresenter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class UserPhotoUploadPresenter {
    private let successView: UserPhotoUploadView?
    private let loadingView: UserPhotoUploadLoadingView?
    private let errorView: UserPhotoUploadLoadingErrorView?
    
    init(
        successView: UserPhotoUploadView,
        loadingView: UserPhotoUploadLoadingView,
        errorView: UserPhotoUploadLoadingErrorView) {
        self.successView = successView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var loadError: String {
        NSLocalizedString("USER_PHOTO_UPLOADER_GET_ERROR",
                          tableName: "UserPhotoUpload",
                          bundle: Bundle.main,
                          comment: "Error message displayed when we can't load the resource from the server")
    }
    
    func didStartLoadingGetUserPhotoUpload() {
        errorView?.display(.noError)
        loadingView?.display(UserPhotoUploadLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingGetUserPhotoUpload(with item: UserPhotoItem) {
        successView?.display(UserPhotoUploadViewModel(item: item))
        loadingView?.display(UserPhotoUploadLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingGetUserPhotoUpload(with error: Error) {
        errorView?.display(.error(message: Self.loadError))
        loadingView?.display(UserPhotoUploadLoadingViewModel(isLoading: false))
    }
}
