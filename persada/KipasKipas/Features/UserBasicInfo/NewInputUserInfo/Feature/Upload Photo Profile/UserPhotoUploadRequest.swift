//
//  UserPhotoUploadRequest.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 19/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

public struct UserPhotoUploadRequest: Encodable {
    let imageData: Data
    let ratio: String
    
    init(imageData: Data, ratio: String) {
        self.imageData = imageData
        self.ratio = ratio
    }
}
