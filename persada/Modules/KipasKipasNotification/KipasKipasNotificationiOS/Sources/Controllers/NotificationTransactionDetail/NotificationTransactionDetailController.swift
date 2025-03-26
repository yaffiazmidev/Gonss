//
//  NotificationTransactionDetailController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 10/05/24.
//

import UIKit
import KipasKipasNotification

class NotificationTransactionDetailController: UIViewController {

    private lazy var mainView: NotificationTransactionDetailView = {
        let view = NotificationTransactionDetailView()
        view.delegate = self
        return view
    }()
    
    let viewModel: INotificationTransactionDetailViewModel
    
    init(viewModel: INotificationTransactionDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchDetail()
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
}

extension NotificationTransactionDetailController: INotificationTransactionDetailView {
    func didClickBackButton() {
        navigationController?.popViewController(animated: true)
    }
}

extension NotificationTransactionDetailController: NotificationTransactionDetailViewModelDelegate {
    func displayTransactionDetail(with item: NotificationTransactionDetailItem) {
        mainView.setupView(with: item)
    }
    
    func displayError(with message: String) {
        print(message)
    }
}
