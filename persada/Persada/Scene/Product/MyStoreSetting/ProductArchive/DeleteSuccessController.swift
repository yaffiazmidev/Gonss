//
//  DeleteSuccessController.swift
//  KipasKipas
//
//  Created by PT.Koanba on 14/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//
import UIKit

class DeleteSuccessController: UIViewController, DeleteSuccessViewDelegate {
    
    private let mainView: DeleteSuccessView
    
    init(mainView: DeleteSuccessView) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.delegate = self
    }
    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func dismisTrashProduct() {
        //dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
