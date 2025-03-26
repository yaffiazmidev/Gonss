//
//  UserPhotoUpload.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UserPhotoUploader {
    typealias Result = Swift.Result<UserPhotoItem, Error>
    
    func upload(request: UserPhotoUploadRequest, completion: @escaping (Result) -> Void)
}
