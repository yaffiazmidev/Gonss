//
//  ImageView+Extension.swift
//  KipasKipasStoryiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/06/24.
//

import UIKit
import KipasKipasShared
import Kingfisher

var ossPerformance = "?x-oss-process=image/format,jpg/interlace,1/resize,w_"
var ossBackgroundImageColor = "?x-oss-process=image/average-hue"

enum OSSSizeImage: String {
    case w40 = "40"
    case w80 = "80"
    case w100 = "100"
    case w140 = "140"
    case w240 = "240"
    case w360 = "360"
    case w480 = "480"
    case w576 = "576"
    case w720 = "720"
    case w1080 = "1080"
    case w1280 = "1280"
}

final class ImageDataLoaderOSS {
    private init() {}

    private static let ossPerformance = "?x-oss-process=image/format,jpg/interlace,1/resize,w_"
    
    static func enrich(_ url: URL, withSize size: OSSSizeImage = .w576) -> URL {
        guard url.absoluteString.contains("kipas") || url.absoluteString.contains("koanba") else { return url }
        return URL(string: "\(url.absoluteString)\(ossPerformance)\(size.rawValue)")!
    }
}

extension UIImageView {
    
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        loadImage(from: URL(string: urlString ?? ""), placeholder: placeholder)
    }
    
    func loadImage(from url: URL?, placeholder: UIImage? = nil) {
        let defaultPlaceholder = UIImage.emptyProfilePhoto
        kf.indicatorType = .activity
        kf.setImage(with: url,
                    placeholder: placeholder ?? defaultPlaceholder,
                    options: [.onlyLoadFirstFrame, .cacheMemoryOnly])
    }
    
    func load(from url: URL?) {
        kf.setImage(with: url, options: [.onlyLoadFirstFrame, .cacheMemoryOnly])
    }
    
    func loadProfileImage(from urlString: String?, size: OSSSizeImage = .w100) {
        guard let urlString = urlString, !urlString.isEmpty else {
            image = .defaultProfileImageCircle
            return
        }
        
        var urlValid = urlString
        if urlString.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlString + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            image = .defaultProfileImageCircle
            return
        }
        
        load(from: url)
    }
    
    func loadImageWithOSS(from urlString: String?, size: OSSSizeImage = .w480) {
        guard let urlString = urlString, !urlString.isEmpty else {
            image = .emptyProfilePhoto
            return
        }
        
        var urlValid = urlString
        if urlString.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlString + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            image = .emptyProfilePhoto
            return
        }
        
        load(from: url)
    }
    
    func cancelLoad() {
        image = nil
        load(from: nil)
    }
}

extension String {
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
