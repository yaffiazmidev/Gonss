//
//  KKQRLayout.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 30/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class KKQRLayout: UIView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    private var error : String = "" {
        didSet {
            self.bindError(error)
        }
    }
    
    var bindError : ((String) -> ()) = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func generateQR(item: KKQRItem, _ completion: @escaping (UIImage) -> ()) {
        let qr = KKQRHelper.generate(item)
        itemName.text = item.data?.name
        qrImageView.image = qr
        if (item.data?.price ?? 0) == 0 {
            itemPrice.isHidden = true
        } else {
            itemPrice.text = item.data!.price!.toMoney()
        }
        itemImageView.loadImageCallback(at: item.data?.image ?? "") {
            guard let image = self.imageWithView(view: self.containerView) else { fatalError("Error generated image") }
            UserDefaults.standard.set(true, forKey: KKQRHelper.userDefaultKey)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(image)
            }
        } errorCompletion: { error in
            self.error = error
        }

    }
    
    private func createIconApp() -> UIImage? {
        let stringName = Bundle.main.infoDictionary!  ["SCHEMA_APPICON"] as! String
        let img_app_icon = UIImage(named: stringName)
        return img_app_icon
    }
    
    func imageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saved custom share for Product \(error)")
        }
    }
    
    class func instanceFromNib() -> KKQRLayout {
        let view = UINib(nibName: "KKQRLayout", bundle: nil).instantiate(withOwner: self, options: nil).first as! KKQRLayout
        view.frame =  CGRect(x: 0, y: 0, width: 393, height: 450)
        return view
    }
}
