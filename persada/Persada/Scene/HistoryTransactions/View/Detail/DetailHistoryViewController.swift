//
//  DetailHistoryViewController.swift
//  KipasKipas
//
//  Created by iOS Dev on 21/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

class DetailHistoryViewController: UIViewController, AlertDisplayer {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = HistoryTransactionDetailViewModel()
    var disposeBag = DisposeBag()
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
        setupTableView()
        setupView()
        self.hud.show(in: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isDetailPenyesuaian.value {
            viewModel.fetchDetailPenyesuaian()
        } else {
            if title != "Penyesuaian Harga" {
                fetchData()
            }
        }
    }
    
    func setupView() {
        setupNavbar()
        if viewModel.isDetailPenyesuaian.value {
            title = "Penyesuaian Harga"
        } else {
            title = viewModel.title
        }
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "DetailLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailLabelCell")
        tableView.register(UINib(nibName: "DetailPhotoTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailProduk")
        tableView.register(UINib(nibName: "InformationHistoryLabelTableViewCell", bundle: nil), forCellReuseIdentifier: "InformationCell")
        tableView.register(UINib(nibName: "InformationListPriceHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "InformationListPriceCell")
        tableView.register(UINib(nibName: "TotalHistoryTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TotalLabelCell")
        tableView.register(UINib(nibName: "AdjustmentTableViewCell", bundle: nil), forCellReuseIdentifier: "AdjustmentCell")
        tableView.register(UINib(nibName: "DetailProductAdjustmentTableViewCell", bundle: nil), forCellReuseIdentifier: "DetailProdukAdjustment")
        tableView.register(UINib(nibName: "ResiNoAdjustmentTableViewCell", bundle: nil), forCellReuseIdentifier: "ResiAdjustment")
        tableView.register(UINib(nibName: "OrderNumberAdjustmentTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderNoAdjustment")
        tableView.register(UINib(nibName: "AdjustmentRefundTableViewCell", bundle: nil), forCellReuseIdentifier: "AdjustmentViewCell")
        tableView.register(UINib(nibName: "DisclaimerTableViewCell", bundle: nil), forCellReuseIdentifier: "DisclaimerAdjustment")
        tableView.register(UINib(nibName: "DestinationAdjustmentTableViewCell", bundle: nil), forCellReuseIdentifier: "DestinationAdjustment")
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = UIColor.clear
        tableView.estimatedRowHeight = 40
    }
    
    func registerObserver() {
        viewModel.data.bind(to: tableView.rx.items) { tableView, index, item in
            switch item.type {
            case .tanggalPembelian:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailLabelCell") as! DetailLabelTableViewCell
                cell.type = self.viewModel.type
                cell.dateDetail = item
                return cell
            case .invoice:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailLabelCell") as! DetailLabelTableViewCell
                cell.type = self.viewModel.type
                cell.invoice = item
                return cell
            case .produk:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailProduk") as! DetailPhotoTableViewCell
                cell.product = item
                return cell
            case .catatan:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationHistoryLabelTableViewCell
                cell.catatan = item
                return cell
            case .penerima:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationHistoryLabelTableViewCell
                cell.penerima = item
                return cell
            case .pembayaran:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationListPriceCell") as! InformationListPriceHistoryTableViewCell
                cell.type = self.viewModel.type
                cell.paymentDetail = item
                cell.action = {
                    self.navigateToDetailPenyesuaian()
                }
                return cell
            case .total:
                let cell = tableView.dequeueReusableCell(withIdentifier: "TotalLabelCell") as! TotalHistoryTransactionTableViewCell
                cell.type = self.viewModel.type
                cell.amount = item
                cell.selectionStyle = .none
                return cell
            case .alamat:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationHistoryLabelTableViewCell
                cell.alamat = item
                return cell
            case .pengiriman:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell") as! InformationHistoryLabelTableViewCell
                cell.pengiriman = item
                return cell
            case .pembayaranRefund:
                let cell = tableView.dequeueReusableCell(withIdentifier: "InformationListPriceCell") as! InformationListPriceHistoryTableViewCell
                cell.type = self.viewModel.type
                cell.paymentDetailRefund = item
                return cell
            case .adjustment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdjustmentCell") as! AdjustmentTableViewCell
                cell.adjustmentModel = item
                return cell
            case .pesananAdjustment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailProdukAdjustment") as! DetailProductAdjustmentTableViewCell
                cell.product = item
                return cell
            case .resiNumberAdjustment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResiAdjustment") as! ResiNoAdjustmentTableViewCell
                cell.noResi = item
                return cell
            case .orderNoAdjustment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderNoAdjustment") as! OrderNumberAdjustmentTableViewCell
                cell.orderNo = item
                return cell
            case .destinationAdjustment:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationAdjustment") as! DestinationAdjustmentTableViewCell
                cell.destination = item
                return cell
            case .adjustmentView:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AdjustmentViewCell") as! AdjustmentRefundTableViewCell
                cell.model = item
                return cell
            case .adjustmentBottom:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DisclaimerAdjustment") as! DisclaimerTableViewCell
                cell.disclaimerLabel.onTap { [weak self] in
                    self?.navigateToTnC()
                }
                return cell
            }
        }.disposed(by: disposeBag)
        
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
    
    func navigateToTnC() {
        let browserController = AlternativeBrowserController(url: .get(.kipasKipasTermsConditionsUrl))
        browserController.bindNavigationBar(.get(.syaratKetentuan), false)
        
        let navigate = UINavigationController(rootViewController: browserController)
        navigate.modalPresentationStyle = .fullScreen

        self.present(navigate, animated: true, completion: nil)
    }
    
    func navigateToDetailPenyesuaian() {
        let newVc = DetailHistoryViewController()
        newVc.viewModel.orderId = viewModel.orderId
        newVc.viewModel.isDetailPenyesuaian.accept(true)
        self.navigationController?.pushViewController(newVc, animated: true)
    }
    
    func fetchData() {
        switch viewModel.type {
        case .transaction, .commission, .reseller:
            viewModel.fetchDataTransaction()
        case .refund:
            viewModel.fetchDataRefund()
        }
    }
}
