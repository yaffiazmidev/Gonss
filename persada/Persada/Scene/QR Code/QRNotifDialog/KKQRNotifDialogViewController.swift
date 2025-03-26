//
//  KKQRNotifDialogViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 30/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class KKQRNotifDialogViewController: UIViewController {

    @IBOutlet weak var closeNotifStackView: UIStackView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var mainView: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let item: KKQRItem
    var didClose: (() -> Void)?
    var didOpen: (() -> Void)?
    
    init(item: KKQRItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.overlayView.alpha = 1.0
            }
        }
        
        setupGestures()
        setupView()
    }
    
    private func setupGestures() {
//        overlayView.onTap { [weak self] in
//            guard let self = self else { return }
//
//            self.dismiss(animated: false)
//            self.didClose?()
//        }
        
        closeNotifStackView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: false)
            self.didClose?()
        }
        
        mainView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.dismiss(animated: false)
            self.didOpen?()
        }
    }
    
    private func setupView(){
        nameLabel.text = item.data?.name
        imageView.loadImage(at: item.data?.image ?? "")
        if (item.data?.price ?? 0) != 0 {
            priceLabel.isHidden = false
            priceLabel.text = item.data?.price?.toMoney()
        }
    }
}
