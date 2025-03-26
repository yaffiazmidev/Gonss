//
//  CoinPurchaseHistoryViewController.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol ICoinPurchaseHistoryViewController: AnyObject {
    func displayPurchaseCoinHistory(contents: [RemoteCurrencyHistoryContent])
    func displayError(messages: String)
}

public class CoinPurchaseHistoryViewController: UIViewController, NavigationAppearance {
    
    private lazy var mainView: CoinPurchaseHistoryView = {
        let view = CoinPurchaseHistoryView().loadViewFromNib() as! CoinPurchaseHistoryView
        view.delegate = self
        return view
    }()
    
    var router: ICoinPurchaseHistoryRouter!
    var interactor: ICoinPurchaseHistoryInteractor!

    public override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        interactor.requestCoinHistory()
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    public override func loadView() {
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        bindNavBar()
        setupNavigationBar(title: "Riwayat Penggunaan Koin", tintColor: .black)
    }
}

extension CoinPurchaseHistoryViewController: CoinPurchaseHistoryViewDelegate {
    
    func didTapDetailIcon(purchaseStatus: CoinPurchaseStatus, purchaseType: CoinActivityType, id: String) {
        router.navigateToCoinPurchaseDetail(purchaseStatus: purchaseStatus, purchaseType: purchaseType, id: id)
    }

    func loadMoreHistories() {
        interactor.requestPage += 1
        interactor.requestCoinHistory()
    }
    
    func pullToRefresh() {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        interactor.requestPage = 0
        interactor.requestCoinHistory()
    }
}

extension CoinPurchaseHistoryViewController: ICoinPurchaseHistoryViewController {
    func displayPurchaseCoinHistory(contents: [RemoteCurrencyHistoryContent]) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        mainView.requestPage = interactor.requestPage
        mainView.totalPage = interactor.totalPage
        mainView.contents = interactor.requestPage == 0 ? contents : mainView.contents + contents
    }
    
    func displayError(messages: String) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        mainView.refreshControl.endRefreshing()
        presentAlert(title: "Error", message: messages)
    }
}
