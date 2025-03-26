//
//  CoinPurchaseViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 09/08/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase
import KipasKipasShared

protocol OldICoinPurchaseViewController: AnyObject {
    func displayCoinProduct(data: [RemoteCoinPurchaseProductData])
    func displayCoinInApp(data: [InAppPurchaseProduct])
    func displayCoinPurchaseTransaction(data: InAppPurchasePaymentTransaction)
    func displayCoinPurchaseValidate(data: CoinInAppPurchaseValidateData)
    func displayCoinPurchaseUserCancel()
    func displayError(message: String)
    func displayUUID(uuid: String)
//    func displayCurrencyInfo(data: RemoteCurrencyInfoData?)
}

public class OldCoinPurchaseViewController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: OldCoinPurchaseView = {
        let view = OldCoinPurchaseView().loadViewFromNib() as! OldCoinPurchaseView
        view.delegate = self
        return view
    }()
    
    var interactor: OldICoinPurchaseInteractor!
    var router: OldICoinPurchaseRouter!
    
    var coinProducts: [RemoteCoinPurchaseProductData] = []
    var coinInApp: [InAppPurchaseProduct] = []
    
    public init() {
        super.init(nibName: "OldCoinPurchaseViewController", bundle: SharedBundle.shared.bundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        interactor.requestCoinProduct()
        //        interactor.requestCurrencyInfo()
        view.backgroundColor = .white | .gunMetal
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadView() {
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        bindNavBar()
        setupNavigationBar(title: "Beli Koin KipasKipas", tintColor: .black)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mainView.historyButton)
    }
}


extension OldCoinPurchaseViewController: OldCoinPurchaseViewDelegate {
    func didTapBuyNow(product id: String) {
        interactor.requestUUID()
    }
    
    func displayUUID(uuid: String) {
        if let id = mainView.selectedCoinProductId,
            let product = coinInApp.first(where: { $0.productIdentifier == id }) {
            KKDefaultLoading.shared.show()
            interactor.requestCoinPurchaseTransaction(product: product, userId: uuid)
        }
    }
    
    func didTapHistoryButton() {
        router.navigateToCoinPurchaseHistory()
    }
    
    func didTapTnC() {
        router.presentTnCWebView()
    }
}

extension OldCoinPurchaseViewController: OldICoinPurchaseViewController {
    func displayCoinProduct(data: [RemoteCoinPurchaseProductData]) {
        KKDefaultLoading.shared.hide()
        coinProducts = data
        mainView.coinProducts = data

        var inAppIds: [String] = []
        data.forEach { product in
            if let id = product.storeProductId {
                inAppIds.append(id)
            }
        }
     
        KKDefaultLoading.shared.show()
        interactor.requestCoinInApp(products: inAppIds)
    }

    func displayCoinInApp(data: [InAppPurchaseProduct]) {
        KKDefaultLoading.shared.hide()
        coinInApp = data
        DispatchQueue.main.async {
            self.mainView.coinInApp = data
        }
    }

    func displayCoinPurchaseTransaction(data: InAppPurchasePaymentTransaction) {
        interactor.requestCoinPurchaseValidate(transaction: data.transactionIdentifier ?? "")
    }
    
    func displayCoinPurchaseValidate(data: CoinInAppPurchaseValidateData) {
        DispatchQueue.main.async {
            KKDefaultLoading.shared.hide()
            self.presentAlert(title: "Pembelian Koin Berhasil", message: "Berhasil membeli koin \(data.orderCoin.detail.coinName)."){ [weak self] in
                self?.router.presentCoinPurchaseDetail(with: data)
            }
        }
    }
    
    func displayCoinPurchaseUserCancel() {
        DispatchQueue.main.async {
            KKDefaultLoading.shared.hide()
        }
    }
    
    func displayError(message: String) {
        DispatchQueue.main.async {
            KKDefaultLoading.shared.hide()
            self.presentAlert(title: "Error", message: message)
        }
    }
}
