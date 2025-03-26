//
//  DonationListViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/02/23.
//

import UIKit
import KipasKipasShared

protocol IDonationListViewController: AnyObject {
    func display(donations: [RemoteDonationContent])
    func displayError(message: String)
}

class DonationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    var interactor: IDonationListInteractor!
    var donations: [RemoteDonationContent] = []
    
	override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        setupTableView()
        interactor.requestDonations()
    }
    
    init(isActive: Bool) {
        super.init(nibName: nil, bundle: nil)
        configure()
        interactor.isActive = isActive
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        tableView.registerNib(DonationListTableViewCell.self)
    }
    
    private func handleTapWithdrawBalanceButton(withdrawaAllowed: Bool, amountAvailable: Double, postDonationId: String) {
        if withdrawaAllowed {
            let vc = WithdrawDonationBalanceRouter.configure(amountAvailable: amountAvailable, campaignId: postDonationId)
            vc.bindNavigationBar()
            vc.handleReloadDonationList = { [weak self] in
                guard let self = self else { return }
                self.handleRefresh()
            }
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = CustomPopUpViewController(
                title: "Maaf, kamu sudah mencapai\nlimit penarikan hari ini",
                description: "Kamu sudah melakukan penarikan saldo sebanyak 2x hari ini, silahkan lakukan\npenarikan lagi di hari berikutnya.",
                iconImage: UIImage(named: "iconWithdrawalLimit")!,
                iconHeight: 120,
                okBtnTitle: "Kembali", isHideIcon: false, okBtnBgColor: .primary
            )
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc private func handleRefresh() {
        interactor.requestPage = 0
        interactor.requestDonations()
    }
}

extension DonationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == donations.count - 1 && interactor.requestPage < interactor.totalPage {
            interactor.requestPage += 1
            interactor.requestDonations()
        }
    }
}

extension DonationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(DonationListTableViewCell.self, for: indexPath)
        let item = donations[indexPath.row]
        cell.setupView(item: item)
        cell.withdrawBalanceButton.onTap { [weak self] in
            guard let self = self else { return }
            self.handleTapWithdrawBalanceButton(withdrawaAllowed: true,
                                                amountAvailable: item.amountAvailable ?? 0,
                                                postDonationId: item.id ?? "")
        }
        
        cell.detailButton.onTap { [weak self] in
            guard let self = self else { return }
            
            let vc = DonationDetailViewController(donationId: self.donations[indexPath.row].id ?? "", feedId: "")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
}

extension DonationListViewController: IDonationListViewController {
    func display(donations: [RemoteDonationContent]) {
        refreshControl.endRefreshing()
        self.donations = interactor.requestPage > 0 ? self.donations + donations : donations
        tableView.reloadData()
        tableView.isEmptyView(self.donations.isEmpty, title: "Belum ada penggalangan dana", image: UIImage(named: "ic_donation_white"))
    }
    
    func displayError(message: String) {
        refreshControl.endRefreshing()
        tableView.isEmptyView(self.donations.isEmpty, title: "Daftar penggalangan dana tidak ditemukan")
        DispatchQueue.main.async {
            Toast.share.show(message: message)
        }
    }
}

extension DonationListViewController {
    private func configure() {
        let presenter = DonationListPresenter(controller: self)
        let network = DIContainer.shared.apiDataTransferService
        interactor = DonationListInteractor(presenter: presenter, network: network)
    }
}
