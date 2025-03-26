//
//  ProductCellSheetView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import Kingfisher

protocol ProductSheetViewProtocol: UIViewController {
    func onBuy(_ product: Product)
    func onShop()
    func onMessage(_ product: Product)
    func onShare(_ product: Product)
}

class ProductSheetViewCell: UICollectionViewCell {
    @IBOutlet var ivProduct: UIImageView!
    @IBOutlet var lPrice: UILabel!
    @IBOutlet var lName: UILabel!
    
    @IBOutlet var ivShop: UIImageView!
    @IBOutlet var ivMessage: UIImageView!
    @IBOutlet var ivShare: UIImageView!
    @IBOutlet var btBuy: UIButton!
    
    var parent: ProductSheetViewProtocol!
    var product: Product!
    
    func setProduct(product p: Product, view v: ProductSheetViewProtocol){
        print("ProductCellSheetView - setProduct")
        self.parent = v
        self.product = p
        setupView()
    }
    
    @IBAction func onBuyTapped(_ sender: Any) {
        parent.dismiss(animated: true)
        self.parent.onBuy(self.product)
    }
}

//MARK: - Helper Methods
extension ProductSheetViewCell {
    func setupView(){
        print("ProductCellSheetView - setupView - \(product.name)")
        
        ivProduct.anchorFeedCleeps(width: UIScreen.main.bounds.width - 32, height: 475)
        lPrice.text = MoneyHelper.toMoney(amount: product.price)
        lName.text = product.name ?? ""
        
        ivShop.onTap { [weak self] in
            guard let self = self else { return }
            self.parent.dismiss(animated: true)
            self.parent.onShop()
        }
        
        ivMessage.onTap { [weak self] in
            guard let self = self else { return }
            self.parent.dismiss(animated: true)
            self.parent.onMessage(self.product)
        }
        
        ivShare.onTap { [weak self] in
            guard let self = self else { return }
            self.parent.dismiss(animated: true)
            self.parent.onShare(self.product)
        }
        
        guard let url = URL(string: product.medias?.first?.thumbnail?.large ?? "") else { return }
        
        ivProduct.loadImage(at: product.medias?.first?.thumbnail?.large ?? "", .w360)
        ivProduct.contentMode = .scaleAspectFill
        
        
        //        KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil) { result in
        //            switch result {
        //            case .success(let v):
        //                self.ivProduct.image = v.image
        //                self.ivProduct.contentMode = .scaleAspectFill
        //            case .failure(let e):
        //                print("Error : \(e)")
        //            }
        //        }
        
    }
}
