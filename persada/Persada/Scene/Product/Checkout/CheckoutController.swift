//
//  CheckoutController.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import KipasKipasShared

final class CheckoutController: UIViewController, CheckoutPresenterLogic {
	
	func areaCovered() {
		mainView.courierNotCoveredView.isHidden = true
		mainView.selectedCourier.isHidden = false
        let param = ParameterCourier(productId: presenter.productId, addressId: AddressPreference.instance.selectedAddressID, quantity: presenter.quantity)
        self.router.chooseCourier(param)
        self.mainView.selectedCourier.stopLoading()
	}
	
	func areaNotCoverage(error: ErrorMessage) {
		showDialogNotCovered(title: .get(.kurirTidakTersedia), desc: .get(.kurirTidakTersediaDesc))
        mainView.addressLabel.textColor = .white
	}
	
	
	func dismiss() {
		
	}
	
	func showDialogNotCovered(title: String, desc: String){
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = .light
            
            alert.addAction(UIAlertAction(title: .get(.back), style: .cancel, handler: { action in
                alert.dismiss(animated: true) {
                    self.mainView.courierNotCoveredView.isHidden = false
                    self.mainView.selectedCourier.isHidden = true
                }
            }))
            alert.addAction(UIAlertAction(title: .get(.gunakanAlamatLain), style: .default, handler: { action in
                alert.dismiss(animated: true) {
                    let pref = AddressPreference.instance
                    if let id = self.addressID {
                        pref.selectedAddressID = id
                    }
                    self.router.changeAddress()
                    self.mainView.selectedCourier.stopLoading()
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
	}
	
	private let mainView: CheckoutView
	private var router: CheckoutRouter!
	private var presenter: CheckoutPresenter!
	private let disposebag = DisposeBag()
	private var addressID : String?
    
    var courier: Courier?
    var price: Int?
    var service: String?
    var duration: String?
    var isCourierSelected = false
    var onProductUpdated: ((_ product: Product) -> Void)?
    
	init(mainView: CheckoutView, productId: String, quantity: Int) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = CheckoutRouter(self)
		presenter = CheckoutPresenter(router: router, productId: productId, quantity: quantity)
		presenter.delegate = self
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
        bindGesture()
//        mainView.setData(product: presenter.item, quantity: presenter.quantity, shipmentPrice: 0)
        mainView.metodePembayaranButton.onTap(action: onMetodePembayaranClicked)
        
        presenter.fetchBuyerAddress()
        presenter.getProductById(id: presenter.productId ) { [weak self] product in
            self?.mainView.setData(product: product, quantity: self?.presenter.quantity ?? 0, shipmentPrice: 0)
            self?.onProductUpdated?(product)
        }
        
        presenter.address.bind { [weak self] (value) in
            guard let self = self else { return }
            if let address = value {
                let addressDefault = "\(address.detail ?? ""), \(address.subDistrict ?? "") \(address.city ?? "") \(address.postalCode ?? "")\n"
                self.mainView.updateAddress(address: addressDefault)
                AddressPreference.instance.selectedAddressID = address.id
//                self.checkCoverage()
            } else {
                AddressPreference.instance.selectedAddressID = nil
            }
        }.disposed(by: disposebag)
		
		presenter.error.bind { (error) in
			if !error!.isEmpty {
                self.showDialogNetworkError(error)
			}
		}.disposed(by: disposebag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = mainView
	}
	
    func send(value: Courier, index: Int) {
		presenter.addCost(value)
        
        courier = value
        price = value.prices?[index].price
        service = value.prices?[index].service
        duration = value.prices?[index].duration
        
        isCourierSelected = true
        mainView.selectedCourier.selectCourierLabel.isHidden = true
        mainView.selectedCourier.titleLabel.text = "\(String(describing: value.name!)) - \(service!)"
        mainView.selectedCourier.titleLabel.font = .Roboto(.bold, size: 13)
        mainView.selectedCourier.titleLabel.textColor = .black
        mainView.selectedCourier.durationLabel.text = value.prices?[index].duration
        mainView.selectedCourier.subtitleLabel.text = String(price!).toMoney()
        
        mainView.biayaKirimPriceLabel.text = String(price!).toMoney()
        mainView.biayaKirimPriceLabel.textColor = .black
        
        mainView.setData(product: presenter.item.value!, quantity: presenter.quantity, shipmentPrice: price!)
		
//		guard let _ = presenter.item?.price,
//					let _ = presenter.total else {
//			return
//		}
		//			configure(value: value, price: price, items: totalItem)
		mainView.layoutIfNeeded()
	}
    
    func onMetodePembayaranClicked(){
        if isCourierSelected && AddressPreference.instance.selectedAddressID != nil {
            self.mainView.metodePembayaranButton.showLoading()
            presenter.getProductById(id: presenter.productId ) { [weak self] product in
                guard let self = self else { return }
                self.onProductUpdated?(product)
                self.validateOrder(product)
            }
        } else {
            self.showDialog(title: .get(.dataBelumLengkap), desc: .get(.dataBelumLengkapDesc))
        }
    }
    
    func validateOrder(_ product: Product){
        if product.stock ?? 0 < self.presenter.quantity {
            self.mainView.metodePembayaranButton.hideLoading()
            self.showDialogEmptyStock()
            return
        }
        
        self.presenter.isOrderDelayed { [weak self] in
            guard let self = self else { return }
            self.showDialogPendingTransaction()
        } notDelayed: { [weak self] in
            guard let self = self else { return }
            self.mainView.metodePembayaranButton.showLoading()
            self.presenter.checkout(order: self.createCheckoutOrderRequest()) { [weak self](url) in
                guard let self = self else { return }
                self.presenter.getProductById(id: self.presenter.productId ) { [weak self] product in
                    guard let self = self else { return }
                    self.onProductUpdated?(product)
                    self.mainView.metodePembayaranButton.hideLoading()
                    self.router.browser(url + "#/bank-transfer")
                }
            } onOutOfStock: {
                self.presenter.getProductById(id: self.presenter.productId ) { [weak self] product in
                    guard let self = self else { return }
                    self.onProductUpdated?(product)
                    self.showDialogEmptyStock()
                }
            }
        }
    }
    
    func createCheckoutOrderRequest() -> CheckoutOrderRequest {
        let product = presenter.item.value
        
        let detailOrder = OrderDetailCheckout(productID: product?.id ?? "", quantity: presenter.quantity, variant: "-", measurement: product?.measurement ?? ProductMeasurement(weight: 0, length: 0, height: 0, width: 0))
        
        let address = presenter.address.value
        
        let shipmentOrder = OrderShipmentCheckout(destinationID: AddressPreference.instance.selectedAddressID ?? "", destinationSubDistrictID: address?.subDistrictId ?? "", notes: self.mainView.notesTextField.text ?? "-", cost: self.price ?? 0, service: self.service ?? "", courier: self.courier? .name ?? "", duration: self.duration ?? "")
        let price = product?.price ?? 0.0
        let total = Double(presenter.quantity) * price + Double(self.price!)
    
        
        let checkout = CheckoutOrderRequest(amount: Int(total), type: "product", orderDetail: detailOrder, orderShipment: shipmentOrder)
        return checkout
    }
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		bindNavigationBar(.get(.checkout))
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backgroundColor = nil
    }
	
	
	func checkCoverage(){
		let param = ParameterCourier(productId: self.presenter.productId, addressId: AddressPreference.instance.selectedAddressID, quantity: self.presenter.quantity)
		if AddressPreference.instance.selectedAddressID != nil {
			self.presenter.checkCourierAvaiable(param)
        } else {
            self.mainView.selectedCourier.stopLoading()
        }
	}
	func bindGesture(){
		let gestureCourier = UITapGestureRecognizer()
		let gestureAddress = UITapGestureRecognizer()
        mainView.selectedCourier.addGestureRecognizer(gestureCourier)
		mainView.addAddressButton.addGestureRecognizer(gestureAddress)
		gestureCourier.rx.event.bind { [weak self] (gesture) in
            guard let self = self else { return }
            self.mainView.selectedCourier.startLoading()
            if AddressPreference.instance.selectedAddressID != nil {
                self.checkCoverage()
            } else {
                self.showDialog(title: .get(.pilihAlamat), desc: .get(.alamatNotChoosen))
                self.mainView.selectedCourier.stopLoading()
            }
		}.disposed(by: disposebag)
		gestureAddress.rx.event.bind { [weak self] (gesture) in
			let pref = AddressPreference.instance
			if let id = self?.addressID {
				pref.selectedAddressID = id
			}
			self?.router.changeAddress()
		}.disposed(by: disposebag)
	}
	
	func updateDataAddress(address: String, id: String){
        AddressPreference.instance.address = address
        AddressPreference.instance.selectedAddressID = id
		if id != addressID {
			
			isCourierSelected = false
            mainView.selectedCourier.selectCourierLabel.isHidden = false
			mainView.selectedCourier.titleLabel.text = ""
			mainView.selectedCourier.subtitleLabel.text = ""
			mainView.selectedCourier.durationLabel.text = ""
            mainView.selectedCourier.stopLoading()
			
			mainView.biayaKirimPriceLabel.text = "0"
			mainView.biayaKirimPriceLabel.textColor = .black
			
            mainView.setData(product: presenter.item.value!, quantity: presenter.quantity, shipmentPrice: 0)
		}
		addressID = id
		mainView.updateAddress(address: address)
        mainView.courierNotCoveredView.isHidden = true
        mainView.selectedCourier.isHidden = false
	}
    
    func showDialog(title: String, desc: String){
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: .get(.ok), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showDialogNetworkError(_ message: String?){
        let serverError = message == "5000"
        let vc = CustomPopUpViewController(title: .get(.errorTitle),description:  serverError ? .get(.errorServer) : message ?? .get(.errorUnknown), okBtnTitle: "Oke", isHideIcon: true)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
        vc.titleLabel.textAlignment = .center
        vc.titleLabel.textColor = .black
        vc.titleLabel.font = .Roboto(.bold, size: 14)
        vc.descLabel.textAlignment = .center
        vc.descLabel.textColor = .grey
        vc.descLabel.font = .Roboto(.regular, size: 12)
        
        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        vc.mainStackView.spacing = 20
        vc.textStackView.spacing = 8
        
        vc.okButton.backgroundColor = .primary
        vc.handleTapOKButton = {
            vc.dismiss(animated: true)
            self.mainView.metodePembayaranButton.hideLoading()
        }
    }
    
    func showDialogEmptyStock(){
        let vc = CustomPopUpViewController(title: .get(.stockNotEnoughtTitle),description: .get(.stockNotEnoughtDesc), okBtnTitle: .get(.backToDetail), isHideIcon: true)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
        vc.titleLabel.textAlignment = .left
        vc.titleLabel.textColor = .black
        vc.titleLabel.font = .Roboto(.bold, size: 14)
        vc.descLabel.textAlignment = .left
        vc.descLabel.textColor = .grey
        vc.descLabel.font = .Roboto(.regular, size: 12)
        
        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        vc.mainStackView.spacing = 14
        
        vc.okButton.backgroundColor = .primary
        vc.handleTapOKButton = {
            self.router.dismiss()
        }
    }
    
    func showDialogPendingTransaction() {
        self.mainView.metodePembayaranButton.hideLoading()
        let vc = CustomPopUpViewController(title: .get(.transaksiTertunda),description: .get(.transaksiTertundaDesc), withOption: true, okBtnTitle: .get(.lanjutkanTransaksi), isHideIcon: true)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
        
        vc.titleLabel.textAlignment = .left
        vc.titleLabel.textColor = .black
        vc.titleLabel.font = .Roboto(.bold, size: 14)
        vc.descLabel.textAlignment = .left
        vc.descLabel.textColor = .grey
        vc.descLabel.font = .Roboto(.regular, size: 12)
        
        let label = UILabel()
        label.attributedText = NSAttributedString(string: .get(.lihatTransaksiYangBelumSelesai), attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        label.textColor = .grey
        label.font = .Roboto(.regular, size: 11)
        label.onTap { [weak self] in
            vc.dismiss(animated: true)
            self?.router.delayedTransaction()
        }
        
        vc.mainStackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 8, right: 20)
        vc.mainStackView.spacing = 14
        vc.mainStackView.insertArrangedSubview(label, at: vc.mainStackView.arrangedSubviews.count - 1)
        
        vc.cancelButton.titleLabel?.text = .get(.batalkan)
        vc.cancelButton.backgroundColor = .white
        vc.cancelButton.tintColor = .contentGrey
        vc.cancelButton.titleLabel?.textAlignment = .right
        vc.cancelButton.titleLabel?.font = .Roboto(.regular, size: 12)
        vc.cancelButton.contentHorizontalAlignment = .right
        
        vc.okButton.backgroundColor = .white
        vc.okButton.tintColor = .secondary
        vc.okButton.titleLabel?.font = .Roboto(.medium, size: 12)
        
        vc.handleTapOKButton = { [weak self] in
            guard let self = self else { return }
            self.mainView.metodePembayaranButton.showLoading()
            self.presenter.checkoutContinue(order: self.createCheckoutOrderRequest()) {  [weak self] (url) in
                guard let self = self else { return }
                self.presenter.getProductById(id: self.presenter.productId ) { [weak self] product in
                    guard let self = self else { return }
                    self.onProductUpdated?(product)
                    self.mainView.metodePembayaranButton.hideLoading()
                    self.router.browser(url + "#/bank-transfer")
                }
            } onOutOfStock: {
                self.presenter.getProductById(id: self.presenter.productId ) { [weak self] product in
                    guard let self = self else { return }
                    self.onProductUpdated?(product)
                    vc.dismiss(animated: true)
                    self.showDialogEmptyStock()
                }
            }
        }
    }
}
