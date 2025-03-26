//
//  PostMediaType.swift
//  KipasKipas
//
//  Created by DENAZMI on 07/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit

public enum PostMediaType {
    case video
    case image
    case multiple
    case product
    case donation
    
    var icon: UIImage? {
        switch self {
        case .video: return UIImage(named: .get(.iconCornerVideo))
        case .image: return UIImage()
        case .multiple: return UIImage(named: .get(.iconCornerStack))
        case .product: return UIImage(named: .get(.iconCornerShopping))
        case .donation: return UIImage(named: .get(.iconDonationWhite))
        }
    }
    
    var profileIcon: UIImage? {
        switch self {
        case .video: return UIImage()
        case .image: return UIImage()
        case .multiple: return UIImage(named: .get(.iconCornerStack))
        case .product: return UIImage(named: .get(.iconCornerShopping))
        case .donation: return UIImage(named: .get(.iconDonationWhite))
        }
    }
    
    static func getIcon(typePost: String, mediaCount: Int, mediaType: String, isContainsProduct: Bool) -> UIImage? {
        let isMultiple = mediaCount > 1
        let isVideo = mediaType == "video"
        let isDonation = typePost == "donation"
        let type: PostMediaType = isDonation ? .donation : isContainsProduct ? .product : isMultiple ? .multiple : isVideo ? .video : .image
        return type.icon
    }
    
    static func getProfileIcon(typePost: String, mediaCount: Int, mediaType: String, isContainsProduct: Bool) -> UIImage? {
        let isMultiple = mediaCount > 1
        let isVideo = mediaType == "video"
        let isDonation = typePost == "donation"
        let type: PostMediaType = isDonation ? .donation : isContainsProduct ? .product : isMultiple ? .multiple : isVideo ? .video : .image
        return type.profileIcon
    }
}
