//
//  StoreKitInAppPurchaseViewController.swift
//  KipasKipasPaymentApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 05/09/23.
//

import UIKit
import KipasKipasPaymentInAppPurchase

class StoreKitInAppPurchaseViewController: UIViewController {
    @IBOutlet var productsCollectionView: UICollectionView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingLabel: UILabel!
    
    let loader: InAppPurchaseProductLoader = StoreKitInAppPurchaseProductLoader()
    let purchaser: InAppPurchaseProductPurchaser = StoreKitInAppPurchaseProductPurchaser()
    
    let userId: String = "402880e78007e0bd0180080b78950003"
    let productIds: [String] = [ //product identifier appstore from backend
        "com.koanba.kipaskipas.mobile.dev.koin_5",
        "com.koanba.kipaskipas.mobile.dev.koin_12",
        "com.koanba.kipaskipas.mobile.dev.koin_24",
        "com.koanba.kipaskipas.mobile.dev.koin_56",
        "com.koanba.kipaskipas.mobile.dev.koin_110",
        "com.koanba.kipaskipas.mobile.dev.koin_135",
        "com.koanba.kipaskipas.mobile.dev.koin_test_invalid",
    ]
    
    var products: [InAppPurchaseProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.productsCollectionView.delegate = self
        self.productsCollectionView.dataSource = self
        let nib = UINib(nibName: "StoreKitInAppPurchaseProductCollectionViewCell", bundle: nil)
        self.productsCollectionView.register(nib, forCellWithReuseIdentifier: "StoreKitInAppPurchaseProductCollectionViewCell")
        self.loadProducts()
    }
}

// MARK: Loader Handler
fileprivate extension StoreKitInAppPurchaseViewController {
    private func loadProducts(){
        self.showLoading("Loading Products...")
        self.loader.load(
            request: InAppPurchaseProductLoaderRequest(identifiers: productIds),
            completion: didReceiveInAppPurchaseProductResponse
        )
    }
    
    private func didReceiveInAppPurchaseProductResponse(response: Result<InAppPurchaseProductsResponse, Error>) {
        DispatchQueue.main.async {
            self.hideLoading()
            
            switch(response){
            case .success(let response):
                self.handleProductsResponse(with: response)
            case .failure(let error):
                print("PE-10921 Error fetch product:", error.localizedDescription)
                self.showAlert(title: "Load Product Error", message: "Failure to Load Product.\n\(error.localizedDescription)")
            }
        }
    }
    
    private func handleProductsResponse(with data: InAppPurchaseProductsResponse) {
        data.invalidProductIdentifiers.forEach { id in
            print("PE-10921 Error fetch product with id:", id)
        }
        
        self.products.append(contentsOf: data.products)
        self.productsCollectionView.reloadData()
    }
}

// MARK: Purchaser handler
fileprivate extension StoreKitInAppPurchaseViewController {
    private func purchase(_ product: InAppPurchaseProduct) {
        self.showAlert(title: "Purchase Product", message: "Do you want to purchase \(product.localizedTitle)?", withCancel: true) {
            self.showLoading("Purchasing \(product.localizedTitle)")
            
            let request = InAppPurchaseProductPurchaserRequest(product: product, applicationUsername: self.userId)
            self.purchaser.purchase(request: request, completion: self.didReceiveInAppPurchaseProductPurchaseResponse)
        }
    }
    
    private func didReceiveInAppPurchaseProductPurchaseResponse(response: Result<InAppPurchasePaymentTransaction, Error>) {
        DispatchQueue.main.async {
            self.hideLoading()
            
            switch(response){
            case .failure(let error):
                print("PE-10921 Error purchase product:", error.localizedDescription)
                self.showAlert(title: "Purchase Product Error", message: "Failure to Purchase Product.\n\(error.localizedDescription)")
            case .success(let transaction):
                self.handlePurchaseResponse(with: transaction)
            }
        }
    }
    
    private func handlePurchaseResponse(with data: InAppPurchasePaymentTransaction) {
        var clip = ""
        clip += "USER ID\t\t\t\t: \(self.userId)\n"
        clip += "APP USERNAME\t\t: \(data.payment.applicationUsername ?? "")\n"
        clip += "TRANSACTION ID\t: \(data.transactionIdentifier ?? "")"
        UIPasteboard.general.string = clip
        self.showAlert(title: "Purchase Product Success", message: "Success to purchase product \(data.payment.productIdentifier).\nCheck your clipboard.")
    }
}

// MARK: Loading handler
fileprivate extension StoreKitInAppPurchaseViewController {
    private func showLoading(_ message: String){
        self.loadingLabel.text = message
        self.loadingView.isHidden = false
    }
    
    private func hideLoading(){
        self.loadingView.isHidden = true
    }
    
    private func showAlert(title: String, message: String, withCancel: Bool = false, completion: (() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if withCancel {
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completion?() })
        self.present(alert, animated: true)
    }
}

// MARK: CollectionView Delegate
extension StoreKitInAppPurchaseViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = self.productsCollectionView.cellForItem(at: indexPath) as? StoreKitInAppPurchaseProductCollectionViewCell{
            self.purchase(self.products[indexPath.item])
        }
    }
}

// MARK: CollectionView Layout Delegate
extension StoreKitInAppPurchaseViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height = 128
        size.width = (size.width - 44) / 2
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// MARK: CollectionView DataSource
extension StoreKitInAppPurchaseViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.productsCollectionView.dequeueReusableCell(withReuseIdentifier: "StoreKitInAppPurchaseProductCollectionViewCell", for: indexPath) as? StoreKitInAppPurchaseProductCollectionViewCell {
            cell.configure(with: self.products[indexPath.item])
            cell.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
            cell.layer.borderWidth = 1
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}
