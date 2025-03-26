//
//  MyBankAccountController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 05/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class MyBankAccountController: UIViewController, AlertDisplayer {
    
    @IBOutlet weak var addBankView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = MyBankAccountViewModel()
    var disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    var choice: ((AccountDestinationModel, Int) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavbar()
        setupView()
        viewModel.fetchBanckAccount()
    }
    
    func registerObserver() {
        viewModel.data.bind(to: tableView.rx.items) { tableView, index, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "DataBankCell") as! MyBankAccountCell
            cell.data = item
            cell.selectionStyle = .none
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let vc = MyBankAccountDetailViewController()
                vc.account = self.viewModel.data.value[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.isLoading.subscribe(onNext: { [weak self] isLoading in
            guard let isLoading = isLoading else { return }
            if isLoading {
                guard let view = self?.view else { return }
                self?.hud.show(in: view)
                return
            } else {
                self?.hud.dismiss()
            }
        }).disposed(by: disposeBag)
        
        viewModel.errorMessage.subscribe(onNext: { [weak self] message in
            guard let message = message else { return }
            if !message.isEmpty {
                let action = UIAlertAction(title: "OK", style: .default)
                self?.displayAlert(with: .get(.error), message: message, actions: [action])
            }
        }).disposed(by: disposeBag)
    }
    
    func setupView() {
        addBankView.layer.borderWidth = 0.5
        addBankView.layer.borderColor = UIColor(hexString: "#EEEEEE").cgColor
        addBankView.layer.masksToBounds = true
        addBankView.layer.cornerRadius = 8
        tableView.register(UINib(nibName: "MyBankAccountCell", bundle: nil), forCellReuseIdentifier: "DataBankCell")
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        
        addBankView.onTap { [weak self] in
            self?.presentAddAcountBank()
        }
    }
    
    func presentAddAcountBank() {
        let vc = FormAddAccountBankViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
}
