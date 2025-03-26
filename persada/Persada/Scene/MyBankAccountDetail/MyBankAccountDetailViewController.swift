//
//  MyBankAccountDetailViewController.swift
//  KipasKipas
//
//  Created by Yaffi Azmi on 25/10/21.
//

import UIKit

class MyBankAccountDetailViewController: UIViewController, AlertDisplayer {
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    var account: AccountDestinationModel?

	override func viewDidLoad() {
        super.viewDidLoad()
        title = String.get(.rekeningSaya)
        setupNavbar()
        
        bankNameLabel.text = account?.namaBank ?? "-"
        accountNumberLabel.text = account?.noRek ?? "-"
        accountNameLabel.text = account?.nama ?? "-"
    }
    
    @IBAction func didClickDeleteAccountButton(_ sender: Any) {
        displayAlert(with: String.get(.hapusRekening), message: String.get(.confirmDeleteAccountBank), actions: [
            UIAlertAction(title: "Hapus", style: .default, handler: { [weak self] action in
                guard let self = self else { return }
                self.navigateToConfirmPassword()
            }),
            UIAlertAction(title: "Cancel", style: .cancel)
        ])
    }
    
    private func navigateToConfirmPassword() {
        let vc = ConfirmPasswordViewController()
        vc.handleSuccessVerifyPassword = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { KKLoading.shared.show() }
            self.deleteBankAccount()
        }
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
    
    
    private func deleteBankAccount() {
        let endpoint: Endpoint<RemoteDonationWithdrawGopay?> = Endpoint(
            path: "/bankaccounts/\(account?.id ?? "")",
            method: .delete,
            headerParamaters: ["Authorization": "Bearer \(getToken() ?? "")", "Content-Type": "application/json"]
        )
        
        DIContainer.shared.apiDataTransferService.request(with: endpoint) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async { KKLoading.shared.hide() }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { Toast.share.show(message: error.message) }
            case .success(_):
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
