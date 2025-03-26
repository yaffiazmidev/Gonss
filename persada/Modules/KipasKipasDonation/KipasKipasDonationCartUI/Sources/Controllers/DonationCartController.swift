//
//  DonationCartController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 01/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking
import KipasKipasShared

public protocol DonationCartControllerDelegate {
    func didOpenVA(_ url: String)
    func didOpenDetail(donation id: String)
}

public class DonationCartController: UIViewController {
    
    let mainView: DonationCartView
    var data: [DonationCart]
    
    let orderExistAdapter: DonationCartOrderExistInteractorAdapter
    let orderAdapter: DonationCartOrderInteractorAdapter
    let orderDetailAdapter: DonationCartOrderDetailInteractorAdapter
    let orderContinueAdapter: DonationCartOrderInteractorAdapter
    
    public var delegate: DonationCartControllerDelegate?
    
    public required init(
        orderExistAdapter: DonationCartOrderExistInteractorAdapter,
        orderAdapter: DonationCartOrderInteractorAdapter,
        orderDetailAdapter: DonationCartOrderDetailInteractorAdapter,
        orderContinueAdapter: DonationCartOrderInteractorAdapter
    ) {
        mainView = DonationCartView()
        data = []
        self.orderExistAdapter = orderExistAdapter
        self.orderAdapter = orderAdapter
        self.orderDetailAdapter = orderDetailAdapter
        self.orderContinueAdapter = orderContinueAdapter
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        mainView.backgroundColor = .white
        
        mainView.collectionView.registerCustomCell(DonationCartViewCell.self)
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        
        let containerView = view!
        containerView.addSubviews([mainView.headerView, mainView.collectionView, mainView.footerView])
        
        mainView.headerView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingRight: 8, height: 34)
        mainView.collectionView.anchor(top: mainView.headerView.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingLeft: 8, paddingRight: 8)
        mainView.footerView.anchor(top: mainView.collectionView.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, height: 80)
        
        setupOnTap()
        loadData()
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: DonationCartManagerNotification.updated, object: nil)
        
    }
}

// MARK: - Private Func
extension DonationCartController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return mainView.collectionView
    }
    
    public var longFormHeight: PanModalHeight {
        return shortFormHeight
    }
    
    public var shortFormHeight: PanModalHeight {
        return .contentHeight(UIScreen.main.bounds.height * 0.4)
    }
    
    public var cornerRadius: CGFloat {
        return 16
    }

    public var allowsTapToDismiss: Bool {
        return true
    }
}

private extension DonationCartController {
    func setupOnTap() {
        mainView.closeView.onTap {
            self.dismiss(animated: true)
        }
        
        mainView.selectView.onTap {
            if self.data.checkedStatus() != .all {
                DonationCartManager.instance.checkAll()
            } else {
                DonationCartManager.instance.uncheckAll()
            }
        }
        
        mainView.donateButton.onTap {
            guard self.mainView.donateButton.isEnabled else { return }
            
            self.checkOrder()
        }
    }
    
    func updateTotal() {
        var total: Double = 0
        for datum in data {
            if datum.checked {
                total += datum.amount
            }
        }
        mainView.updateTotal(total)
    }
    
    func createParam() -> DonationCartOrderParam {
        var total: Int = 0
        var items: [DonationCartOrderItemParam] = []
        data.forEach { cart in
            if cart.checked {
                total += Int(cart.amount)
                items.append(
                    DonationCartOrderItemParam(
                        amount: Int(cart.amount),
                        orderDetail: DonationCartOrderDetailParam(feedId: cart.id)
                    )
                )
            }
        }
        return DonationCartOrderParam(cartDonations: items, totalAmount: total)
    }
    
    func showOrderExist(_ orderId: String) {
        let vc = CustomPopUpViewController(
            title: "Masih ada transaksi yang belum selesai.",
            description: "Masih ada transaksi donasi yang belum kamu selesaikan. Lanjutkan donasi jika ingin membatalkan transaksi sebelumnya, atau pergi ke transaksi sebelumnya.",
            withOption: true,
            cancelBtnTitle: "Ke transaksi sebelumnya",
            okBtnTitle: "Lanjutkan donasi",
            isHideIcon: true,
            okBtnBgColor: .primary,
            actionStackAxis: .vertical
        )
        
        vc.handleTapOKButton = { [weak self] in
            guard let self = self else { return }
            
            self.continueCheckout()
        }
        
        vc.handleTapCancelButton = { [weak self] in
            guard let self = self else { return }
            
            self.checkDetail(order: orderId)
        }
        
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        
        present(vc, animated: true, completion: nil)
    }
}

// MARK: Data
private extension DonationCartController {
    @objc func loadData() {
        data = DonationCartManager.instance.data
        if data.isEmpty {
            dismiss(animated: true)
            return
        }
        
        let status = data.checkedStatus()
        mainView.donateButtonEnable(status != .none)
        mainView.updateCheckboxState(with: status)
        mainView.collectionView.reloadData()
        updateTotal()
    }
    
    func checkOrder() {
        KKDefaultLoading.shared.show()
        
        orderExistAdapter.load { [weak self] result in
            guard let self = self else { return }
            
            KKDefaultLoading.shared.hide()
            
            switch result {
            case let .success(exist):
                if exist.orderExist {
                    self.showOrderExist(exist.orderId ?? "")
                } else {
                    self.checkout()
                }
            case let .failure(error):
                self.showToast(with: "Gagal memuat data.\n\(self.errorMessage(error))")
            }
        }
    }
    
    func checkout() {
        KKDefaultLoading.shared.show()
        
        orderAdapter.load(createParam()) { [weak self] result in
            guard let self = self else { return }
            
            KKDefaultLoading.shared.hide()
            
            switch result {
            case let .success(order):
                DonationCartManager.instance.clearChecked()
                self.dismiss(animated: true) {
                    self.delegate?.didOpenVA(order.redirectUrl)
                }
            case let .failure(error):
                self.showToast(with: "Gagal membuat order.\n\(self.errorMessage(error))")
            }
        }
    }
    
    func continueCheckout() {
        KKDefaultLoading.shared.show()
        
        orderContinueAdapter.load(createParam()) { [weak self] result in
            guard let self = self else { return }
            
            KKDefaultLoading.shared.hide()
            
            switch result {
            case let .success(order):
                DonationCartManager.instance.clearChecked()
                self.dismiss(animated: true) {
                    self.delegate?.didOpenVA(order.redirectUrl)
                }
            case let .failure(error):
                self.showToast(with: "Gagal membuat order.\n\(self.errorMessage(error))")
            }
        }
    }
    
    func checkDetail(order id: String) {
        KKDefaultLoading.shared.show()
        
        orderDetailAdapter.load(by: id) { [weak self] result in
            guard let self = self else { return }
            
            KKDefaultLoading.shared.hide()
            
            switch result {
            case let .success(order):
                self.dismiss(animated: true) {
                    self.delegate?.didOpenVA(order.orderDetail.urlPaymentPage)
                }
            case let .failure(error):
                self.showToast(with: "Gagal memuat data.\n\(self.errorMessage(error))")
            }
        }
    }
    
    func errorMessage(_ error: Error) -> String {
        if let error = error as? KKNetworkError {
            return error.errorDescription ?? error.localizedDescription
        }
        
        return error.localizedDescription
    }
}

// MARK: - CollectionView DataSource
extension DonationCartController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// MARK: - CollectionView Delegate
extension DonationCartController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: DonationCartViewCell.self, indexPath: indexPath)
        let data = data[indexPath.item]
        
        cell.configure(with: data)
        
        cell.changeLabel.onTap {
            let vc = DonationInputAmountViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.handleCreateOrderDonation = { [weak self] amount in
                guard self != nil else { return }
                
                if amount == data.amount { return }
                
                var update = data
                update.amount = amount
                DonationCartManager.instance.update(update)
            }
            self.present(vc, animated: true)
            
            vc.donationType = .update
            vc.donationAmount = data.amount
            vc.donationAmountTextField.text = "\(Int(data.amount))".digits().toMoney(withCurrency: false)
        }
        
        cell.removeView.onTap {
            DonationCartManager.instance.remove(data)
        }
        
        cell.checkboxView.onTap {
            var update = data
            update.checked = !data.checked
            DonationCartManager.instance.update(update)
        }
        
        return cell
    }
}

// MARK: - CollectionView Flow Delegate
extension DonationCartController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 8, right: 8)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = collectionView.frame.size
        size.height = 83
        return size
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
