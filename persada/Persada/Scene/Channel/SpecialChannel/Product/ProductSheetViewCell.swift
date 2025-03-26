//
//  ProductCellSheetView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductSheetViewCellDelegate {
    func onShop()
    func onMessage(_ product: ProductItem)
    func onShare(_ product: ProductItem)
    func onBuy(_ product: ProductItem)
    func onPlayVideo(_ product: ProductItem)
}

class ProductSheetViewCell: UICollectionViewCell {
    @IBOutlet var ivProduct: UIImageView!
    @IBOutlet var ivPlay: UIImageView!
    @IBOutlet var lPrice: UILabel!
    @IBOutlet var lName: UILabel!
    
    @IBOutlet var ivShop: UIImageView!
    @IBOutlet var ivMessage: UIImageView!
    @IBOutlet var ivShare: UIImageView!
    @IBOutlet var btBuy: UIButton!
    
    var parent: ProductSheetView!
    var product: ProductItem!
    var delegate: ProductSheetViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    func setProduct(product: ProductItem, from: ProductSheetView, delegate: ProductSheetViewCellDelegate){
        self.parent = from
        self.product = product
        self.delegate = delegate
        setupView()
    }
}

//MARK: - Helper Methods
extension ProductSheetViewCell {
    func setupView(){
        
        ivProduct.anchor(width: UIScreen.main.bounds.width - 32, height: 475)
        lPrice.text = product.price.toMoney()
        lName.text = product.name ?? ""
        
        let firstMediaIsVideo = product.medias?.first?.type == "video"
        ivPlay.isHidden = !firstMediaIsVideo
        if firstMediaIsVideo {
            ivPlay.onTap {
                self.delegate.onPlayVideo(self.product)
            }
        }
        
        ivShop.onTap {
            self.delegate.onShop()
        }
        
        ivMessage.onTap {
            self.delegate.onMessage(self.product)
        }
        
        ivShare.onTap {
            self.delegate.onShare(self.product)
        }
        
        btBuy.onTap {
            self.delegate.onBuy(self.product)
        }
        
        guard let url = product.medias?.first?.thumbnail?.large else { return }
        
        ivProduct.loadImage(at: url, .w360)
        ivProduct.contentMode = .scaleAspectFill
    }
    
    private func addShadow() {
        contentView.layer.cornerRadius = 6.0
        contentView.layer.borderWidth = 0.1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 2)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.2
        layer.masksToBounds = false
//        let rect = CGRect(x: -2.0, y: -1.0, width: contentView.bounds.width + 25, height: contentView.bounds.height - 15)
//
//        layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: contentView.layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor.clear.cgColor
    }
}
