//
//  CallProfileSocialMedia.swift
//  KipasKipasCall
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import Foundation

public struct CallProfileSocialMedia: Hashable {
    
    public let urlSocialMedia: String?
    public let socialMediaType: String
    
    public init(urlSocialMedia: String?, socialMediaType: String) {
        self.urlSocialMedia = urlSocialMedia
        self.socialMediaType = socialMediaType
    }
}
