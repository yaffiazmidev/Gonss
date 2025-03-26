//
//  ProfileLoaderRequest.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

// MARK: Kalo ada waktu, tolong dirapiin ya 
struct ProfileLoaderDataRequest {
    let userId: String
    let username: String
    
    init(userId: String = "", username: String = "") {
        self.userId = userId
        self.username = username
    }
}

struct ProfileLoaderMutualRequest { 
    let targetAccountId: String
}

struct ProfileLoaderUpdatePictureRequest {
    let userId: String
    let pictureUrl: String
}
