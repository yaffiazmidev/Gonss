//
//  DiamondWithdrawalDetailViewController.swift
//  KipasKipasDirectMessage
//
//  Created by DENAZMI on 11/08/23.
//

import UIKit
import KipasKipasDirectMessage

public protocol IDiamondWithdrawalDetailViewController: AnyObject {
    func displayHistoryDetail(data: RemoteCurrencyHistoryDetailData?)
    func displayError(message: String)
}

public class DiamondWithdrawalDetailViewController: UIViewController {
    
    private lazy var mainView: DiamondWithdrawalDetailView = {
        let view = DiamondWithdrawalDetailView().loadViewFromNib() as! DiamondWithdrawalDetailView
        view.delegate = self
        return view
    }()
    
	var interactor: IDiamondWithdrawalDetailInteractor!
	var router: IDiamondWithdrawalDetailRouter!
    
    let withdrawalStatus: DiamondPurchaseStatus
    let type: DiamondActivityType
    var historyDetail: RemoteCurrencyHistoryDetailData?
    let historyDetailId: String
    
    public init(
        withdrawalStatus: DiamondPurchaseStatus = .process,
        type: DiamondActivityType,
        id: String,
        historyDetail: RemoteCurrencyHistoryDetailData?
    ) {
        self.withdrawalStatus = withdrawalStatus
        self.type = type
        self.historyDetailId = id
        self.historyDetail = historyDetail
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        interactor.requestMyCurreny()
        requestDetail()
    }
    
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        title = type == .withdrawal ? "Penarikan Diamond" : "Pertambahan Diamond"
    }
    
    private func requestDetail() {
        guard !historyDetailId.isEmpty else {
            mainView.setupView(item: historyDetail, withdrawalStatus, type)
            return
        }
        
        DispatchQueue.main.async { KKDefaultLoading.shared.show() }
        mainView.setupView(item: nil, withdrawalStatus, type)
        interactor.requestHistoryDetail(id: historyDetailId)
    }
}

extension DiamondWithdrawalDetailViewController: DiamondWithdrawalDetailViewDelegate {
    
}

extension DiamondWithdrawalDetailViewController: IDiamondWithdrawalDetailViewController {
    public func displayHistoryDetail(data: RemoteCurrencyHistoryDetailData?) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
        historyDetail = data
        mainView.setupView(item: data, withdrawalStatus, type)
    }
    
    public func displayError(message: String) {
        DispatchQueue.main.async { KKDefaultLoading.shared.hide() }
//        presentAlert(title: "Error", message: message)
    }
}
