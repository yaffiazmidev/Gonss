//
//  BankAccountController.swift
//  KipasKipasDirectMessageUI
//
//  Created by Muhammad Noor on 05/09/23.
//

import UIKit
import KipasKipasDirectMessage

protocol IBankAccountController: AnyObject {
    func displayBankAccount(bank: [Banks], gopay: [Banks])
}

class BankAccountController: UIViewController {
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(BankAccountCell.self, forCellReuseIdentifier: "cellId")
        table.backgroundColor = UIColor(hexString: "#FAFAFA")
        table.separatorStyle = .none
        table.isOpaque = true
        table.delegate = self
        table.dataSource = self
        table.accessibilityIdentifier = "tableview-bankacount"
        return table
    }()
    
    var interactor: IBankAccountInteractor!
    var router: IBankAccountRouter!
    var gopay: [Banks] = []
    var bank: [Banks] = []
    var selectedBank: ((BankAccountItem) -> Void)?
 
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        requestBank()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideUserInterfaceStyle = .light
        title = "Penarikan Diamond"
        view.backgroundColor = .white
        bindNavBar()
    }
    
    func setUp() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
    }
    
    private func requestBank() {
        interactor.getBank()
    }
}

extension BankAccountController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bank.count
        } else {
            return gopay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! BankAccountCell
            let bank = bank[indexPath.item]
            cell.setup(value: bank)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! BankAccountCell
            let gopay = gopay[indexPath.item]
            cell.setup(value: gopay)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 238/255, green: 236/255, blue: 238/255, alpha: 1)
        
        if section == 0 {
            let titleLabel = UILabel()
            titleLabel.frame = CGRect(x: 10, y: 10, width: view.frame.width - 24, height: 14)
            titleLabel.text = "Bank"
            titleLabel.font = .Roboto(.bold, size: 12)
            titleLabel.textColor = .black
            headerView.addSubview(titleLabel)
            return headerView
        } else {
            let titleIcon = UIImageView(image: UIImage.set(.get(.imgGopay)))
            titleIcon.frame = CGRect(x: 10, y: 10, width: 74, height: 14)
            titleIcon.clipsToBounds = true
            titleIcon.contentMode = .scaleAspectFit
            headerView.addSubview(titleIcon)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .white
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 10, y: 10, width: view.frame.width - 24, height: 14)
        titleLabel.font = .Roboto(.bold, size: 12)
        if section == 0 {
            titleLabel.text = "+  Tambah akun bank"
            titleLabel.textColor = .systemBlue
        } else {
            titleLabel.text = "Belum bisa melakukan penarikan dengan gopay"
            titleLabel.textColor = UIColor(hexString: "#777777")
            titleLabel.font = .Roboto(.medium, size: 12)
        }
        footerView.addSubview(titleLabel)
        
        footerView.onTap { [weak self] in
            guard let self = self else { return }
            
            if section == 0 {
//                self.presentAddAcountBank()
            } else {
//                let vc = AddGopayAccountViewController()
//                vc.handleSendOTPCallback = { [weak self] bank in
//                    guard let self = self else { return }
//                    self.navigateToOTPMethodOption(bank: bank)
//                }
//                let nav = UINavigationController(rootViewController: vc)
//                nav.modalPresentationStyle = .overFullScreen
//                self.present(nav, animated: true)
            }
        }
        if section == 0 {
            return bank.count >= 2 ? nil : footerView
        } else {
            return gopay.count >= 2 ? nil : footerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 35 }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return bank.count >= 2 ? 0 : 38
        } else {
            return gopay.count >= 2 ? 0 : 38
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let item = bank[indexPath.item]
            selectedBank?(BankAccountItem(bankId: item.id ?? "", username: item.accountName ?? "", nameBank: item.bank?.name ?? "", noRekening: item.accountNumber ?? "", withdrawalFee: item.withdrawFee ?? 0))
        } else {
            let item = gopay[indexPath.item]
            selectedBank?(BankAccountItem(bankId: item.id ?? "", username: item.accountName ?? "", nameBank: item.bank?.name ?? "", noRekening: item.accountNumber ?? "", withdrawalFee: item.withdrawFee ?? 0))
        }
        navigationController?.popViewController(animated: true)
    }
}

extension BankAccountController: IBankAccountController {
    func displayBankAccount(bank: [Banks], gopay: [Banks]) {
        DispatchQueue.main.async {
            self.bank = bank
            // hide dulu karena BE belum ready
//            self.gopay = gopay
            self.tableView.reloadData()
        }
    }
}
