//
//  InAppPurchaseViewController.swift
//  KipasKipasPaymentApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 06/09/23.
//

import UIKit

class InAppPurchaseViewController: UIViewController {
    @IBOutlet var storeKitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapStoreKit))
        storeKitButton.addGestureRecognizer(gesture)
    }
    
    @objc private func onTapStoreKit() {
        let controller = StoreKitInAppPurchaseViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
