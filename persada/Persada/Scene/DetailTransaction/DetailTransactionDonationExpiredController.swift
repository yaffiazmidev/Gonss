//
//  DetailTransactionDonationExpiredController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class DetailTransactionDonationExpiredController: UIViewController, UIGestureRecognizerDelegate{
    private let mainView: DetailTransactionDonationExpiredView!
    
    var loader: RemoteDetailTransactionOrderLoader!
    private let orderId: String
    private var data: DetailTransactionOrderItem?
    
    init(_ orderId: String){
        self.orderId = orderId
        self.mainView = DetailTransactionDonationExpiredView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        loadData()
        mainView.configure(data)
        setupAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.backgroundColor = nil
    }
}

// MARK: - ACTION Handler
extension DetailTransactionDonationExpiredController {
    private func setupAction(){
        mainView.backButton.onTap { self.back() }
        mainView.reorderButton.onTap {
            guard let donationId = self.data?.orderDetail.postDonationId,let feedId = self.data?.orderDetail.feedId else{ return }
            let vc = DonationDetailViewController(donationId: donationId, feedId: feedId)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension DetailTransactionDonationExpiredController {
    private func loadData(){
        loader.load(request: .init(id: orderId)) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.data = data
                    self.mainView.configure(self.data)
                }
            case .failure(let error):
                DispatchQueue.main.async { self.displayAlertFailure(error.getErrorMessage()) }
            }
        }
    }
}


extension DetailTransactionDonationExpiredController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default){ _ in
            self.back()
        }
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}
