//
//  CustomShareModel.swift
//  KipasKipas
//
//  Created by PT.Koanba on 22/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit

struct CustomShareModel {
    let icon: UIImage?
    let title: String
    let type: CustomShareType
}

enum CustomShareType {
    case instagramDirectMessage
    case instagramFeed
    case instagramStory
    case whatsapp
    case whatsappStatus
    case facebook
    case saveToGallery
    case copyLink
    case report
    case delete
    case more
}
