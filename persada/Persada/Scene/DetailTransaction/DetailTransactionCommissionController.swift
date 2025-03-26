//
//  ResellerSetProductController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking

class DetailTransactionCommissionController: UIViewController {
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var sellerImageView: UIImageView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerUsernameLabel: UILabel!
    @IBOutlet weak var sellerVerifiedImageVIew: UIImageView!
    @IBOutlet weak var resellerCommissionTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var loader: RemoteDetailTransactionOrderLoader!
    private let orderId: String
    private var data: DetailTransactionOrderItem?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        loadData()
    }
    
    init(_ orderId: String){
        self.orderId = orderId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension DetailTransactionCommissionController: UIGestureRecognizerDelegate {
     private func setupNavBar() {
        title = .get(.detailCommission)
        navigationController?.hideKeyboardWhenTappedAround()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupView(){
        guard let data = self.data else { return }
        productImageView.loadImage(at: data.orderDetail.urlProductPhoto)
        productTitleLabel.text = data.orderDetail.productName
        productPriceLabel.text = data.orderDetail.productPrice.toMoney()

        sellerImageView.loadImage(at: data.orderDetail.urlSellerPhoto)
        sellerNameLabel.text = data.orderDetail.sellerName
        sellerUsernameLabel.text = "@\(data.orderDetail.sellerUserName.replacingOccurrences(of: "@", with: ""))"
        sellerVerifiedImageVIew.isHidden = !data.orderDetail.isSellerVerified
        resellerCommissionTextField.text = data.orderDetail.commission.toMoney().replacingOccurrences(of: "Rp ", with: "")
    }
}

extension DetailTransactionCommissionController {
    private func loadData(){
        loadingIndicator.startAnimating()
        loader.load(request: .init(id: orderId)) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.loadingIndicator.stopAnimating() }
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.data = data
                    self.setupView()
                }
            case .failure(let error):
                DispatchQueue.main.async { self.displayAlertFailure(error.getErrorMessage()) }
            }
        }
    }
}


extension DetailTransactionCommissionController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default){ _ in
            self.back()
        }
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}
