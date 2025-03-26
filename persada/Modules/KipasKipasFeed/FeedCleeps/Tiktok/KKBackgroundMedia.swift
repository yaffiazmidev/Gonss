//
//  KKBackgroundMedia.swift
//  FeedCleeps
//
//  Created by Muhammad Noor on 26/07/23.
//

import Foundation
import UIKit

class KKBackgroundMedia {
    
    static let instance = KKBackgroundMedia()
    
    func colour(_ urlPath: String, imgView: UIImageView) -> UIImageView {
        if(urlPath == "") {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        guard !urlPath.contains("digitalocean") else {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        guard let url = URL(string: urlPath) else {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        requestURL(url, imageView: imgView)
        
        return imgView
    }
    
    func original(_ urlPath: String, imgView: UIImageView) -> UIImageView {
        imgView.backgroundColor = nil
        if(urlPath == "") {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        guard !urlPath.contains("digitalocean") else {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        imgView.loadImageWithoutOSS(at: urlPath)
        
        return imgView
    }
    
    func blur(_ urlPath: String, imgView: UIImageView) -> UIImageView {
        imgView.backgroundColor = nil
        if(urlPath == "") {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
        guard !urlPath.contains("digitalocean") else {
            imgView.image = UIImage(named: .get(.empty))
            return imgView
        }
        
//        let customURL = urlPath +  ossPerformance + "120" + "/blur,r_8,s_8"
//        imgView.loadImage(at: urlPath)
        
        let customURL = urlPath +  ossPerformance + "200" + "/blur,r_50,s_35"
        imgView.loadImage(at: customURL)
        
        return imgView
    }
    
    private func requestURL(_ url: URL, imageView: UIImageView) {
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            let decode = try? JSONDecoder().decode([String:String].self, from: data)
            DispatchQueue.main.async {
                imageView.backgroundColor = UIColor(hexString: decode?["RGB"] ?? "")
            }
        }.resume()
    }
}
