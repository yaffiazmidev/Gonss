//
//  ViewController.swift
//  KipasKipasPaymentApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var iapButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapIAP))
        iapButton.addGestureRecognizer(gesture)
    }
    
    @objc private func onTapIAP() {
        let controller = InAppPurchaseViewController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
}

