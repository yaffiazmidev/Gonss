//
//  UserPhotoUploadViewProtocols.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UserPhotoUploadView {
    func display(_ viewModel: UserPhotoUploadViewModel)
}

protocol UserPhotoUploadLoadingView {
    func display(_ viewModel: UserPhotoUploadLoadingViewModel)
}

protocol UserPhotoUploadLoadingErrorView {
    func display(_ viewModel: UserPhotoUploadLoadingErrorViewModel)
}
