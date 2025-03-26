//
//  HotnewsBackgroundCoverManager.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/12/23.
//

import Foundation
import UIKit
import Kingfisher

struct HotnewsCoverMedia {
    var image: HotnewsCoverType
    var video: ((Bool) -> HotnewsCoverType)
    
    init(image: HotnewsCoverType, video: @escaping ((Bool) -> HotnewsCoverType)) {
        self.image = image
        self.video = video
    }
    
    static func original() -> HotnewsCoverMedia {
        return HotnewsCoverMedia(image: .original, video: { _ in .original })
    }
    
    static func blur() -> HotnewsCoverMedia {
        return HotnewsCoverMedia(image: .blur, video: { _ in .blur })
    }
    
    static func thematic() -> HotnewsCoverMedia {
        return HotnewsCoverMedia(image: .thematic, video: { _ in .thematic })
    }
}

enum HotnewsCoverMediaType {
    case photo
    case video(isFill: Bool)
}

enum HotnewsCoverType {
    case original
    case blur
    case thematic
}

class HotnewsCoverManager {
    private static var _instance: HotnewsCoverManager?
    private static let lock = NSLock()
    
    var themeUrl: String = "https://koanba-storage-prod.oss-cn-hongkong.aliyuncs.com/img/thumbnail/background-blur.png"
//    var type: [FeedType: HotnewsCoverType] = [
//        .donation: .original,
//        .hotNews: .original,
//        .feed: .thematic,
//        .otherProfile: .thematic,
//        .profile: .thematic,
//    ]
    var type: [FeedType: HotnewsCoverMedia] = [
        .donation: .init(image: .original, video: { fill in fill ? .original : .blur }),
        .hotNews: .init(image: .original, video: { fill in fill ? .original : .blur }),
        .feed: .init(image: .thematic, video: { fill in fill ? .original : .blur }),
        .otherProfile: .init(image: .thematic, video: { fill in fill ? .original : .blur }),
        .profile: .init(image: .thematic, video: { fill in fill ? .original : .blur }),
    ]
    
    static var instance: HotnewsCoverManager {
        if _instance == nil {
            lock.lock()
            defer {
                lock.unlock()
            }
            if _instance == nil {
                _instance = HotnewsCoverManager()
            }
        }
        return _instance!
    }
    
    private init() {}
    
//    func url(from string: String, with feedType: FeedType, mediaType: HotnewsCoverMediaType) -> String {
//        let type = type[feedType]
//        
//        if type == .thematic && mediaType == .photo {
//            return themeUrl
//        }
//        
//        var url = string
//        if !url.contains("x-oss-process"){
//            url = ("\(url)?x-oss-process=image/format,jpg/interlace,1/resize,w_360")
//        }
//        
//        return url
//    }
    
    func url(from string: String, with feedType: FeedType, mediaType: HotnewsCoverMediaType) -> String {
        guard let media = type[feedType] else {
            return url(from: string, with: .blur)
        }
        
        if case .video(let isFill) = mediaType {
            let type = media.video
            return url(from: string, with: type(isFill))
        }
        
        return url(from: string, with: media.image)
    }
}

// MARK: - Helper
private extension HotnewsCoverManager {
    private func url(from string: String, with type: HotnewsCoverType) -> String {
        if type == .thematic {
             return themeUrl
        }
        
        var url = string
        if !url.contains("x-oss-process"){
            url = ("\(url)?x-oss-process=image/format,jpg/interlace,1/resize,w_360")
        }
        
        if type == .blur {
            return "\(url)/blur,r_50,s_35"
        }
        
        return url
    }
}
