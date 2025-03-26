//
//  ProductView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 26/05/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import FittedSheets
//import RxSwift
//import SwiftUI
import KipasKipasNetworking

protocol ProductSheetPresenter {
    static func openSheet(from parent: UIViewController, loader: RemoteProductListLoader, feed: Feed, products p: [ProductItem]?, delegate: ProductSheetDelegate)
}

protocol ProductSheetDelegate {
    func onShop(_ feed: Feed)
    func onMessage(_ product: ProductItem, _ feed: Feed)
    func onShare(_ product: ProductItem, _ feed: Feed)
    func onBuy(_ product: ProductItem, _ feed: Feed)
    func onPlayVideo(_ product: ProductItem)
}

class ProductSheetView: UIViewController, AlertDisplayer {
    
    @IBOutlet var cvUserProduct: UICollectionView!
    private var listLoader: RemoteProductListLoader!
    var delegate: ProductSheetDelegate!
    
    var sheetFullScreen: Bool!
    var onSheetReachTop: (() -> Void)!
    
    private var feed: Feed!
    private var products: [ProductItem] = []
    private var page: Int = 0
    private var totalPages: Int = 0
    private var onLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProductSheetView - viewDidLoad")
        cvUserProduct.register(UINib(nibName: "ProductSheetViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCell")
        //        cvUserProduct.contentInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        setupDelegate()
    }
    
    func refreshUI() {
        self.page = 0
        self.totalPages = 0
        loadList()
    }
    
    func setupData(loader: RemoteProductListLoader, feed: Feed, products: [ProductItem]? = []){
        self.listLoader = loader
        self.feed = feed
        self.products = products ?? []
        self.cvUserProduct.reloadData()
    }
    
    func setupDelegate() {
        self.cvUserProduct.delegate = self
        self.cvUserProduct.dataSource = self
    }
}

// MARK: - Sheet Delegate
extension ProductSheetView: ProductSheetPresenter {
    static func openSheet(from parent: UIViewController, loader: RemoteProductListLoader, feed: Feed, products: [ProductItem]?, delegate: ProductSheetDelegate) {
        let sb = UIStoryboard(name: "ProductSheetView", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "productSheetController")
        
        let opt = SheetOptions(useInlineMode: false)
        let svc = SheetViewController(
            controller: vc,
            sizes: [.percent(0.75), .fullscreen],
            options: opt)
        
        parent.present(svc, animated: true, completion: nil)
        let view = vc as! ProductSheetView
        view.setupData(loader: loader, feed: feed, products: products)
        if AUTH.isLogin() {
            view.refreshUI()
        }
        view.delegate = delegate
        view.sheetFullScreen = false
        view.cvUserProduct.isScrollEnabled = false
        svc.sizeChanged = { sheet, size, height in
            view.sheetFullScreen = (height == parent.view.frame.height)
            view.cvUserProduct.isScrollEnabled = view.sheetFullScreen
            if size == .fullscreen {
                UIApplication.shared.statusBarStyle = .darkContent
            }else {
                UIApplication.shared.statusBarStyle = .lightContent
            }
        }
        view.onSheetReachTop = {
            svc.resize(to: .percent(0.75))
        }
    }
}

// MARK: - Collection View Data Source and Delegate
extension ProductSheetView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -20 && sheetFullScreen {
            cvUserProduct.isScrollEnabled = false
            self.onSheetReachTop()
            
            //Uncomment & adjust ini untuk pagination
//            if !onLoading && (page + 1) < totalPages {
//                page += 1
//                loadList()
//            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 450)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("ProductSheetView - cellForItemAt")
        
        let cell = cvUserProduct.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductSheetViewCell
        cell.setProduct(product: products[indexPath.row], from: self, delegate: self)
        
        return cell
    }
}
//MARK: - Loader Implementataion
extension ProductSheetView {
    private func loadList(){
        let request = ProductListLoaderRequest(accountId: feed.account?.id ?? "", page: page, type: ProductType.all.rawValue)
        self.onLoading = true
        listLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                DispatchQueue.main.async {
                    self.onLoading = false
                    self.updateProducts(item)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.onLoading = false
                    let title = String.get(.error)
                    let action = UIAlertAction(title: .get(.ok), style: .default)
                    self.displayAlert(with: title , message: self.getErrorMessage(error), actions: [action])
                    self.cvUserProduct.reloadData()
                }
            }
        }
    }
    
    private func updateProducts(_ result: ProductArrayItem){
        var dataFilter: [ProductItem] = []
        if let id = products.first?.id {
            dataFilter = result.data.filter { product in
                product.id != id
            }
        }
        self.products.append(contentsOf: dataFilter)
        self.totalPages = result.totalPages
        self.cvUserProduct.reloadData()
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        if let error = error as? KKNetworkError {
            switch error {
            case .connectivity:
                return "Gagal menghubungkan ke server"
            case .invalidData:
                return "Gagal memuat data"
            case .responseFailure(let error):
                return "Gagal memuat data\n\(error.message)"
            default:
                return error.localizedDescription
            }
        }
        
        return error.localizedDescription
    }
}

extension ProductSheetView: ProductSheetViewCellDelegate{
    func onShop() {
        dismiss(animated: true)
        delegate.onShop(feed)
    }
    
    func onMessage(_ product: ProductItem) {
        self.dismiss(animated: true)
        delegate.onMessage(product, feed)
    }
    
    func onShare(_ product: ProductItem) {
        self.dismiss(animated: true)
        delegate.onShare(product, feed)
    }
    
    func onBuy(_ product: ProductItem) {
        self.dismiss(animated: true)
        delegate.onBuy(product, feed)
    }
    
    func onPlayVideo(_ product: ProductItem) {
        self.dismiss(animated: true)
        delegate.onPlayVideo(product)
    }
}
