//
//  DefaultPopViewController.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
protocol ProductArchiveMenuPopUp {
    func archiveProductMenu(_ menuModel: ProductArchiveModel.Menu, id: String)
}

class DefaultPopViewController: UIViewController  {
  
     var delegate: ProductArchiveMenuPopUp?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var vPopup: UIView!
    @IBOutlet weak var btnActiveProduct: UIButton!
    @IBOutlet weak var btnEditProduct: UIButton!
    @IBOutlet weak var btnDeleteProduct: UIButton!
    
    public var descPopup = ""
    public var buttonTextActiveProduct = ""
    public var buttonTextEditProduct = ""
    public var buttonTextDeleteProduct = ""
    public var isCloseHidden = true
    public var idArchiveProduct: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupView(){
        vPopup.layer.cornerRadius = 8
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.clickAction(sender:)))
        self.bgView.addGestureRecognizer(gesture)
    }
    
    private func setupButton(){
        btnActiveProduct.titleLabel?.text = buttonTextActiveProduct
        btnActiveProduct.setTitle(buttonTextActiveProduct, for: .normal)
        btnEditProduct.titleLabel?.text = buttonTextEditProduct
        btnEditProduct.setTitle(buttonTextEditProduct, for: .normal)
        btnDeleteProduct.titleLabel?.text = buttonTextDeleteProduct
        btnDeleteProduct.setTitle(buttonTextDeleteProduct, for: .normal)
    }
    
    @IBAction func btnActiveProduct(_ sender: Any) {
        delegate?.archiveProductMenu(.active, id: idArchiveProduct)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnEditProduct(_ sender: Any) {
        //delegate?.archiveProductMenu(.edit)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDeleteProduct(_ sender: Any) {
        //delegate?.archiveProductMenu(.delete)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func clickAction(sender : UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
