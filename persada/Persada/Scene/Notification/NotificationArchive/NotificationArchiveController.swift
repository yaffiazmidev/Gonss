//
//  NotificationArchiveController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class NotificationArchiveController: UIViewController, UIGestureRecognizerDelegate {
    private let mainView: NotificationArchiveView!
    
    init(){
        self.mainView = NotificationArchiveView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Produk"
        view = mainView
        navigationController?.hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = nil
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}
