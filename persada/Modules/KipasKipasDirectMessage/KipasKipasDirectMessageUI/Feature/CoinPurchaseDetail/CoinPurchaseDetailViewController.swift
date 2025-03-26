//
//  CoinPurchaseDetailViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage

public protocol ICoinPurchaseDetailViewController: AnyObject {
    func displayHistoryDetail(data: RemoteCurrencyHistoryDetailData?)
    func displayError(message: String)
}

public class CoinPurchaseDetailViewController: UIViewController {
    
    private lazy var mainView: CoinPurchaseDetailView = {
        let view = CoinPurchaseDetailView().loadViewFromNib() as! CoinPurchaseDetailView
        view.delegate = self
        return view
    }()
    
	var interactor: ICoinPurchaseDetailInteractor!
	var router: ICoinPurchaseDetailRouter!
    let purchaseStatus: CoinPurchaseStatus
    var historyDetail: RemoteCurrencyHistoryDetailData?
    let historyDetailId: String
    let isPresent: Bool
    
    private let purchaseType: CoinActivityType
    
    public init(
        isPresent: Bool = false,
        purchaseStatus: CoinPurchaseStatus,
        purchaseType: CoinActivityType,
        id: String,
        historyDetail: RemoteCurrencyHistoryDetailData?
    ) {
        self.purchaseStatus = purchaseStatus
        self.purchaseType = purchaseType
        self.historyDetailId = id
        self.historyDetail = historyDetail
        self.isPresent = isPresent
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        requestDetail()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = purchaseType == .topup ? "Detail Pembelian Koin" : "Detail Penggunaan Koin"
        bindNavBar(isPresent: isPresent)
        mainView.setupView(purchaseStatus: purchaseStatus, type: purchaseType)
    }
    
    private func requestDetail() {
        guard !historyDetailId.isEmpty else {
            mainView.setupView(purchaseStatus: purchaseStatus, type: purchaseType)
            mainView.setupComponent(item: historyDetail)
            return
        }
        
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        mainView.setupView(purchaseStatus: purchaseStatus, type: purchaseType)
        interactor.requestHistoryDetail(id: historyDetailId)
    }
}

extension CoinPurchaseDetailViewController: CoinPurchaseDetailViewDelegate {
    
}

extension CoinPurchaseDetailViewController: ICoinPurchaseDetailViewController {
    public func displayHistoryDetail(data: RemoteCurrencyHistoryDetailData?) {
        historyDetail = data
        mainView.setupComponent(item: data)
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
    }
    
    public func displayError(message: String) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
//        presentAlert(title: "Error", message: message)
    }
}
