//
//  TransactionDetailDonationController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

public class TransactionDetailDonationController: UIViewController {

    private lazy var mainView: TransactionDetailDonationView = {
        let view = TransactionDetailDonationView()
        view.delegate = self
        return view
    }()
    
    let viewModel: ITransactionDetailDonationViewModel
    
    var handleShowUserProfile: ((String) -> Void)?
    var handleShowDonationGroupOrder: ((DonationTransactionDetailGroupItem?) -> Void)?
    
    init(viewModel: ITransactionDetailDonationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        defaultRequest()
    }
    
    public override func loadView() {
        view = mainView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func defaultRequest() {
        viewModel.fetchDetail()
        viewModel.fetchOrder()
        viewModel.fetchGroupOrder()
    }
}

extension TransactionDetailDonationController: ITransactionDetailDonationView {
    func didClickGroupOrder(item: DonationTransactionDetailGroupItem?) {
        handleShowDonationGroupOrder?(item)
    }
    
    func didCopy(value: String) {
        UIPasteboard.general.string = value
        DispatchQueue.main.async { Toast.share.show(message: "Success copy to clipboard", textColor: .white, bgColor: UIColor(hexString: "#4A4A4A"), cornerRadius: 4) }
    }
    
    func didClickBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func didClickPayNowButton(url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url)
        }
    }
    
    func didClickInitiatorProfile(id: String) {
        handleShowUserProfile?(id)
    }
}

extension TransactionDetailDonationController: TransactionDetailDonationViewModelDelegate {
    public func displayDetail(with item: NotificationTransactionDetailItem) {
        mainView.item = item
    }
    
    public func displayOrder(with item: DonationTransactionDetailOrderItem) {
        mainView.orderItem = item
    }
    
    public func displayGroupOrder(with item: DonationTransactionDetailGroupItem) {
        mainView.groupOrderItem = item
        mainView.groupOrderCountLabel.text = "+ \(item.donations.count) donation"
        mainView.groupOrderContainerStack.isHidden = item.donations.isEmpty
    }
    
    public func displayErrorDetail(with message: String) {
        print(message)
    }
    
    public func displayErrorOrder(with message: String) {
        print(message)
    }
    
    public func displayErrorGroupOrder(with message: String) {
        print(message)
    }
}
