//
//  UserPhotoUploadService.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class UserPhotoUploadService: UserPhotoUploadControllerDelegate {
    
    private let uploader: UserPhotoUploader
    var presenter: UserPhotoUploadPresenter?
    
    init(uploader: UserPhotoUploader) {
        self.uploader = uploader
    }
    
    func didUserPhotoUpload(request: UserPhotoUploadRequest) {
        presenter?.didStartLoadingGetUserPhotoUpload()
        uploader.upload(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingGetUserPhotoUpload(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingGetUserPhotoUpload(with: error)
            }
        }
    }
}
