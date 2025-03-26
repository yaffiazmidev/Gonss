//
//  DetailTransactionDonationSuccessController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import UIKit

class DetailTransactionDonationSuccessController: UIViewController, UIGestureRecognizerDelegate{
    private let mainView: DetailTransactionDonationSuccessView!
    
    var loader: RemoteDetailTransactionOrderLoader!
    private let orderId: String
    private var data: DetailTransactionOrderItem?
    
    init(_ orderId: String){
        self.orderId = orderId
        self.mainView = DetailTransactionDonationSuccessView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func loadView() {
        super.loadView()
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail Transaksi"
        navigationController?.hideKeyboardWhenTappedAround()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
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
extension DetailTransactionDonationSuccessController {
    private func setupAction(){
        mainView.backButton.onTap { self.back() }
        mainView.organizerCardView.onTap {
            guard let id = self.data?.orderDetail.initiatorId else { return }
            let controller = AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource(id: id))
            controller.setProfile(id: id, type: "")
            controller.bindNavigationBar("", true)
            controller.fromHome = false
            controller.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        mainView.reorderButton.onTap {
            guard let donationId = self.data?.orderDetail.postDonationId,let feedId = self.data?.orderDetail.feedId else{ return }
            let vc = DonationDetailViewController(donationId: donationId, feedId: feedId)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
}

extension DetailTransactionDonationSuccessController {
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


extension DetailTransactionDonationSuccessController: AlertDisplayer {
    private func displayAlertFailure(_ errorMessage: String){
        let action = UIAlertAction(title: .get(.ok), style: .default){ _ in
            self.back()
        }
        self.displayAlert(with: .get(.failed), message: errorMessage, actions: [action])
    }
}
