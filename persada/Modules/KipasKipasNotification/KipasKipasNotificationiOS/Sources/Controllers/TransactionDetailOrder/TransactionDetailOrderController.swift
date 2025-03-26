//
//  TransactionDetailOrderController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 12/05/24.
//

import UIKit
import KipasKipasNotification
import KipasKipasDonationTransactionDetail

public class TransactionDetailOrderController: UIViewController {

    private lazy var mainView: TransactionDetailOrderView = {
        let view = TransactionDetailOrderView()
        view.delegate = self
        return view
    }()
    
    let viewModel: ITransactionDetailOrderViewModel
    
    init(viewModel: ITransactionDetailOrderViewModel) {
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
    
    private func defaultRequest() {
        viewModel.fetchDetail()
        viewModel.fetchOrder()
    }
}

extension TransactionDetailOrderController: ITransactionDetailOrderView{
    func didClickBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension TransactionDetailOrderController: TransactionDetailOrderViewModelDelegate {
    public func displayDetail(with item: NotificationTransactionDetailItem) {
        mainView.item = item
    }
    
    public func displayOrder(with item: DonationTransactionDetailOrderItem) {
        
    }
    
    public func displayErrorDetail(with message: String) {
        print(message)
    }
    
    public func displayErrorOrder(with message: String) {
        print(message)
    }
}
