//
//  DiamondWithdrawalHistoryViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit
import KipasKipasDirectMessage
import KipasKipasShared

protocol IDiamondWithdrawalHistoryViewController: AnyObject {
    func displayWithdrawalDiamondHistory(contents: [RemoteCurrencyHistoryContent])
    func displayError(messages: String)
}

class DiamondWithdrawalHistoryViewController: UITableViewController, NavigationAppearance {
    
    private lazy var mainView: DiamondWithdrawalHistoryView = {
        let view = DiamondWithdrawalHistoryView().loadViewFromNib() as! DiamondWithdrawalHistoryView
        view.delegate = self
        return view
    }()
    
	var interactor: IDiamondWithdrawalHistoryInteractor!
	var router: IDiamondWithdrawalHistoryRouter!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        interactor.requestWithdrawalDiamondHistory()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func loadView() {
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        bindNavBar()
        setupNavigationBar(title: "Riwayat Penarikan Diamond", tintColor: .black)
    }
}

extension DiamondWithdrawalHistoryViewController: DiamondWithdrawalHistoryViewDelegate {
    func loadMoreHistories() {
        interactor.requestPage += 1
        interactor.requestWithdrawalDiamondHistory()
    }
    
    func pullToRefresh() {
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        interactor.requestPage = 0
        interactor.requestWithdrawalDiamondHistory()
    }
    
    func didTapDetailIcon(
        status: DiamondPurchaseStatus,
        type: DiamondActivityType,
        id: String
    ) {
        router.navigateToDiamondWithdrawalDetail(
            status: status,
            type: type,
            id: id
        )
    }
}

extension DiamondWithdrawalHistoryViewController: IDiamondWithdrawalHistoryViewController {
    func displayWithdrawalDiamondHistory(contents: [RemoteCurrencyHistoryContent]) {
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
