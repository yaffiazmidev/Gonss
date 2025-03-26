//
//  Ext-UIImageView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 15/07/23.
//

import UIKit
import Kingfisher
import KipasKipasDirectMessage

extension UIImageView {
    func setImage(_ name: String) {
        image = UIImage.set(name)
    }
    
    func loadImage(from urlString: String?, placeholder: UIImage? = nil) {
        loadImage(from: URL(string: urlString ?? ""), placeholder: placeholder)
    }
    
    func loadImage(from url: URL?, placeholder: UIImage? = nil) {
        let defaultPlaceholder = UIImage.set("empty")
        kf.indicatorType = .activity
        kf.setImage(with: url,
                    placeholder: placeholder ?? defaultPlaceholder,
                    options: [.onlyLoadFirstFrame, .cacheMemoryOnly])
    }
    
    func load(from url: URL?) {
        kf.setImage(with: url, options: [.onlyLoadFirstFrame, .cacheMemoryOnly])
    }
}
