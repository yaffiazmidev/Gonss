//
//  UIImage.swift
//  Persada
//
//  Created by Muhammad Noor on 27/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit

extension UIImage {
	class func colorForNavBar(_ color: UIColor) -> UIImage {
		let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		context!.setFillColor(color.cgColor)
		context!.fill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return image!
	}
	
	var scaledToSafeUploadSize: UIImage? {
		let maxImageSideLength: CGFloat = 480
		
		let largerSide: CGFloat = max(size.width, size.height)
		let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
		let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
		
		return image(scaledTo: newImageSize)
	}
	
	func image(scaledTo size: CGSize) -> UIImage? {
		var scaledImageRect = CGRect.zero
		
		let aspectWidth:CGFloat = size.width / self.size.width
		let aspectHeight:CGFloat = size.height / self.size.height
		let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
		
		scaledImageRect.size.width = self.size.width * aspectRatio
		scaledImageRect.size.height = self.size.height * aspectRatio
		scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
		scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		
		self.draw(in: scaledImageRect)
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage
	}
	
	func image(resizedTo size: CGSize) -> UIImage? {
		defer {
			UIGraphicsEndImageContext()
		}
		
		UIGraphicsBeginImageContextWithOptions(size, false, 0)
		draw(in: CGRect(origin: .zero, size: size))
		
		return UIGraphicsGetImageFromCurrentImageContext()
	}
	
	func imageWithColor(color: UIColor) -> UIImage? {
		var image = withRenderingMode(.alwaysTemplate)
		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		color.set()
		image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		image = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return image
	}

		var roundedImage: UIImage {
			let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
			UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
			UIBezierPath(
				roundedRect: rect,
				cornerRadius: 50
			).addClip()
			self.draw(in: rect)
			return UIGraphicsGetImageFromCurrentImageContext()!
		}

}
