//
//  UIImageView+Extension.swift
//  KipasKipas
//
//  Created by movan on 23/09/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Kingfisher

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

extension UIImageView {
	
    func loadImageCallback(at urlPath: String, _ size: OSSSizeImage = .w576, completion: @escaping () -> (), errorCompletion: @escaping (String) -> ()) {

        if(urlPath == "") {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlPath + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        let placeholderImage = UIImage(named: .get(.empty))
        self.kf.indicatorType = .activity
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
                completion()
            }
            .onFailure { error in
                errorCompletion(error.errorDescription ?? "unknown error")
            }
            .set(to: self)
    }
    
    func loadImageWithoutOSS(at urlPath : String, placeholder: UIImage? = UIImage(named: .get(.empty))) {

        if(urlPath == "") {
            self.image = placeholder
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = placeholder
            return
        }
        
        guard let url = URL(string: urlPath) else {
            self.image = placeholder
            return
        }
        
        let processor = DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))
                     |> RoundCornerImageProcessor(cornerRadius: 8)
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        let placeholderImage = placeholder
        self.kf.indicatorType = .activity
        KF.url(url)
            .placeholder(placeholderImage)
            .loadDiskFileSynchronously()
            .retry(retry)
            .setProcessor(processor)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
    
    //func loadImage(at urlPath: String, _ size: OSSSizeImage = .w576) {
    func loadImage(at urlPath: String, _ size: OSSSizeImage = .w240, emptyImageName: String = .get(.empty)) {
        //print("****** loadImage",urlPath)
        
        if(urlPath == "") {
            //self.image = UIImage(named: .get(.emptyImageName))
            self.image = UIImage(named: emptyImageName)
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            //self.image = UIImage(named: .get(.empty))
            self.image = UIImage(named: emptyImageName)
            return
        }
        
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: "\(ossPerformance.split(separator: "=").first!)") == false {
            urlValid = urlPath + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            //self.image = UIImage(named: .get(.empty))
            self.image = UIImage(named: emptyImageName)
            return
        }
        
		let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2))
        
		//let placeholderImage = UIImage(named: .get(.empty))
        let placeholderImage = UIImage(named: emptyImageName)
		//self.kf.indicatorType = .activity
        self.kf.indicatorType = .none
        
		KF.url(url)
			.placeholder(placeholderImage)
			.loadDiskFileSynchronously()
			.retry(retry)
			//.cacheMemoryOnly()
			.onProgress { receivedSize, totalSize in
			}
			.onSuccess { result in
			}
			.onFailure { error in
			}
			.set(to: self)
	}
	
    func loadImage(at urlPath: String, low urlLowResPath : String, _ size: OSSSizeImage = .w576, _ sizeLowRes: OSSSizeImage = .w576) {
        
        if(urlPath == "") {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        var urlValid = urlPath
        if urlPath.containsIgnoringCase(find: ossPerformance) == false {
            urlValid = urlPath + ossPerformance + size.rawValue
        }
        
        guard let url = URL(string: urlValid) else {
            self.image = UIImage(named: .get(.empty))
            return
        }
        
        var lowUrlValid = urlLowResPath
        if urlLowResPath.containsIgnoringCase(find: ossPerformance) == false {
            lowUrlValid = urlLowResPath + ossPerformance + sizeLowRes.rawValue
        }
		
		guard let lowUrl = URL(string: lowUrlValid) else {
            self.image = UIImage(named: .get(.empty))
			return
		}
		
		let retry = DelayRetryStrategy(maxRetryCount: 3, retryInterval: .seconds(2))
		
		
		let placeholderImage = UIImage(named: .get(.empty))
		self.kf.indicatorType = .activity
		KF.url(url)
			.placeholder(placeholderImage)
			.loadDiskFileSynchronously()
			.retry(retry)
			//.cacheMemoryOnly()
			.lowDataModeSource(.network(lowUrl))
			.onProgress { receivedSize, totalSize in
			}
			.onSuccess { result in
			}
			.onFailure { error in
			}
			.set(to: self)
	}
    
    func load(at urlPath : String, placeholder: UIImage?) {
        
        if(urlPath == "") {
            self.image = placeholder
            return
        }
        
        guard !urlPath.contains("digitalocean") else {
            self.image = placeholder
            return
        }
        
        guard let url = URL(string: urlPath) else {
            self.image = placeholder
            return
        }
        
        let processor = DownsamplingImageProcessor(size: CGSize(width: 150, height: 150))
                     |> RoundCornerImageProcessor(cornerRadius: 8)
        let retry = DelayRetryStrategy(maxRetryCount: 1, retryInterval: .seconds(1))
        
        self.kf.indicatorType = .activity
        KF.url(url)
            .placeholder(placeholder)
            .loadDiskFileSynchronously()
            .retry(retry)
            .setProcessor(processor)
            //.cacheMemoryOnly()
            .onProgress { receivedSize, totalSize in
            }
            .onSuccess { result in
            }
            .onFailure { error in
            }
            .set(to: self)
    }
	
	//Responsiblity: to holds the List of Activity Indicator for ImageView
	//DataSource: UI-Level
	struct ActivityIndicator {
			static var isEnabled = false
        static var style = UIActivityIndicatorView.Style.large
        static var view = UIActivityIndicatorView(style: .large)
	}
	
	//MARK: Public Vars
	public var isActivityEnabled: Bool {
			get {
					guard let value = objc_getAssociatedObject(self, &ActivityIndicator.isEnabled) as? Bool else {
							return false
					}
					return value
			}
			set(newValue) {
					objc_setAssociatedObject(self, &ActivityIndicator.isEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
	}
	public var activityStyle: UIActivityIndicatorView.Style {
			get{
					guard let value = objc_getAssociatedObject(self, &ActivityIndicator.style) as? UIActivityIndicatorView.Style else {
							return .whiteLarge
					}
					return value
			}
			set(newValue) {
					objc_setAssociatedObject(self, &ActivityIndicator.style, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
	}
	public var activityIndicator: UIActivityIndicatorView {
			get {
					guard let value = objc_getAssociatedObject(self, &ActivityIndicator.view) as? UIActivityIndicatorView else {
							return UIActivityIndicatorView(style: .whiteLarge)
					}
					return value
			}
			set(newValue) {
					let activityView = newValue
					activityView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
					activityView.hidesWhenStopped = true
					objc_setAssociatedObject(self, &ActivityIndicator.view, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
	}
	
	//MARK: - Private methods
	func showActivityIndicator() {
			if isActivityEnabled {
					DispatchQueue.main.async {
						self.backgroundColor = .black
							self.activityIndicator = UIActivityIndicatorView(style: self.activityStyle)
							if !self.subviews.contains(self.activityIndicator) {
									self.addSubview(self.activityIndicator)
							}
							self.activityIndicator.startAnimating()
					}
			}
	}
	
	func hideActivityIndicator() {
			if isActivityEnabled {
					DispatchQueue.main.async {
							self.backgroundColor = UIColor.white
							self.subviews.forEach({ (view) in
									if let av = view as? UIActivityIndicatorView {
											av.stopAnimating()
									}
							})
					}
			}
	}

	func roundCornersForAspectFit(radius: CGFloat)
	{
		if let image = self.image {

			//calculate drawingRect
			let boundsScale = self.bounds.size.width / self.bounds.size.height
			let imageScale = image.size.width / image.size.height

			var drawingRect: CGRect = self.bounds

			if boundsScale > imageScale {
				drawingRect.size.width =  drawingRect.size.height * imageScale
				drawingRect.origin.x = (self.bounds.size.width - drawingRect.size.width) / 2
			} else {
				drawingRect.size.height = drawingRect.size.width / imageScale
				drawingRect.origin.y = (self.bounds.size.height - drawingRect.size.height) / 2
			}
			let path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
			let mask = CAShapeLayer()
			mask.path = path.cgPath
			self.layer.mask = mask
		}
	}

    func image(_ t: String) -> Self {
        image = UIImage(named: t)
        return self
    }
}
