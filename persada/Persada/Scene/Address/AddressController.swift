//
//  AddressController.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class AddressController: UIViewController, AlertDisplayer, UITableViewDelegate {
	
	private var mainView: AddressView!
	private var mainViewCheckout: AddressCheckoutView!
	private var router: AddressRouter!
	private var presenter : AddressPresenter!
	private let disposeBag = DisposeBag()
	private var checkout = false
	
	init(mainView: AddressView, type: AddressFetchType) {
		self.mainView = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = AddressRouter(self)
		presenter = AddressPresenter(router: router, type: type)
	}
	
	init(mainView: AddressCheckoutView, type: AddressFetchType) {
		self.mainViewCheckout = mainView
		
		super.init(nibName: nil, bundle: nil)
		router = AddressRouter(self)
		presenter = AddressPresenter(router: router, type: type)
		checkout = true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if checkout {
			setTableViewCheckout()
		
			self.mainViewCheckout.searchBar.delegate = self
		} else {
			setTableView()
			
			self.mainView.searchBar.delegate = self
		}
		
		
		createObservers()
		createErrorObserver()
		setAlamatUtama()
	}
	
	func setAlamatUtama(){
		if !checkout {
			let value = presenter.addressResult.value.filter { (address) -> Bool in
                address.isDefault ?? false || address.isDelivery ?? false
			}
			
			AddressPreference.instance.selectedAddressID = value.first?.id
			let address = "\(value.first?.detail ?? ""), \(value.first?.subDistrict ?? "") \(value.first?.city ?? "") \(value.first?.postalCode ?? "")\n"
			AddressPreference.instance.address = address
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        if presenter.type.value == .buyer {
            bindNavigationBar(.get(.alamatPenerima))
        } else {
            bindNavigationBar(.get(.shopAddress))
        }
		
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
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = nil
//        navigationController?.hidesBarsOnSwipe = false
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 100))
		
		footerView.addSubview(mainViewCheckout.buttonAddAddress)
		footerView.bounds = footerView.frame.insetBy(dx: 0, dy: -10)
		mainViewCheckout.buttonAddAddress.fillSuperview()
		return footerView
	}

	func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 48.0
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if AddressPreference.instance.selectedAddressID == "" {
			let selectedAddress = presenter.addressResult.value[indexPath.row].isDefault ?? false
			if selectedAddress {
				tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
			}
		} else {
			let selectedAddress = presenter.addressResult.value[indexPath.row].id == AddressPreference.instance.selectedAddressID
			if selectedAddress {
				tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
			}
		}
		
	}
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let address = presenter.addressResult.value[indexPath.item]
        let name = ((address.senderName?.isEmpty ?? true) ? address.receiverName : address.senderName) ?? "-"
        let phoneNumber = address.phoneNumber ?? "-"
        let fullAddress = "\(address.detail ?? ""), \(address.subDistrict ?? "") \(address.city ?? "") \(address.postalCode ?? "")"
        
        let width = tableView.frame.size.width - 100
        let nameHeight = name.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 20), font:  .Roboto(.medium, size: 12))
        let phoneNumberHeight = phoneNumber.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 20), font:  .Roboto(.medium, size: 12))
        let fullAddressHeight = fullAddress.height(withConstrainedWidth: width - calculatePercentage(value: width, percentageVal: 20), font:  .Roboto(.regular, size: 12))
        
        let alamatUtamaHeight = CGFloat((address.isDefault ?? false) ? 34 : 12)
        
        let height = nameHeight + phoneNumberHeight + fullAddressHeight + alamatUtamaHeight + 4 + 8 + 45
        return height
    }
    
    func calculatePercentage(value:CGFloat, percentageVal:CGFloat) -> CGFloat{
        let val = value * percentageVal
        return val / 100.0
    }
	
	func setTableView(){
		presenter.addressResult.asObservable().bind(to: mainView.tableView.rx.items(cellIdentifier: AddressView.ViewTrait.cellId, cellType: AddressItemCell.self)) { index, model, cell in
			
			cell.configure(with: model)
		}.disposed(by: disposeBag)
		
		mainView.tableView.rx.itemSelected.observeOn(MainScheduler.instance)
			.subscribe {[weak self] (path) in
				self?.presenter.didSelectRowTrigger.onNext(path.row)
			}.disposed(by: disposeBag)
		
		presenter.isEmpty.bind { [weak self] (isEmpty) in
            if let isEmpty = isEmpty {
                self?.mainView.isAlreadyHaveData = isEmpty
            }
		}.disposed(by: disposeBag)
        
        presenter.type
            .map { $0 == .seller}
            .bind(to: mainView.searchBar.rx.isHidden)
            .disposed(by: disposeBag)
        
        presenter.type
            .asObservable()
            .map { $0 == .seller}
            .observeOn(MainScheduler.instance)
            .bind { status in
                if status == true {
                    self.mainView.topTableViewConstraint = self.mainView.tableView.topAnchor.constraint(equalTo: self.mainView.topAnchor, constant: 16)
                    self.mainView.topTableViewConstraint?.isActive = true
                }
            }.disposed(by: disposeBag)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Observable.zip(self.presenter.addressResult.asObservable(), self.presenter.type.asObservable()) { (items, type) in
                    items.count != 0 && type == .seller
                }
            .observeOn(MainScheduler.instance)
            .bind { status in
                self.mainView.buttonAddAddress.isHidden = status
            }.disposed(by: self.disposeBag)
        }
	}
	
	
	func setTableViewCheckout(){
		presenter.addressResult.asObservable().bind(to: mainViewCheckout.tableView.rx.items(cellIdentifier: AddressView.ViewTrait.cellId, cellType: AddressCheckoutItemCell.self)) { index, model, cell in
			
			cell.configure(with: model)
			
			cell.handleEdit = {
				self.presenter.didSelectRowTrigger.onNext(index)
			}
		}.disposed(by: disposeBag)
		
		presenter.isEmpty.bind { [weak self] (isEmpty) in
            if let isEmpty = isEmpty {
                self?.mainViewCheckout.isAlreadyHaveData = isEmpty
            }
		}.disposed(by: disposeBag)
		
		
		
		mainViewCheckout.tableView.rx.setDelegate(self).disposed(by: disposeBag)
		
		mainViewCheckout.buttonSave.rx.tap.bind { [weak self] (_) in
			let pref = AddressPreference.instance
			self?.router.dismissAndUpdate(address: pref.address ?? "", id: pref.selectedAddressID ?? "")
		}.disposed(by: disposeBag)
	}
	
	func createErrorObserver(){
		presenter.errorRelay.bind { (error) in
			if let error = error?.localizedDescription {
				let action = UIAlertAction(title: StringEnum.ok.rawValue, style: .default)
				self.displayAlert(with: StringEnum.error.rawValue, message: error, actions: [action])
			}
		}.disposed(by: disposeBag)
	}
	
	

	
	override func loadView() {
		if checkout {
			view = mainViewCheckout
			view.backgroundColor = .white
			mainViewCheckout.tableView.refreshControl = mainViewCheckout.refreshControl
			mainViewCheckout.refreshControl.addTarget(self, action: #selector(handlePulltoRequest), for: .valueChanged)
			mainViewCheckout.buttonAddAddress.addTarget(self, action: #selector(handleAddAddressButton), for: .touchUpInside)
			
			mainViewCheckout.buttonAddAddressBottom.addTarget(self, action: #selector(handleAddAddressButton), for: .touchUpInside)
		} else {
			view = mainView
			view.backgroundColor = .white
			mainView.tableView.refreshControl = mainView.refreshControl
			mainView.refreshControl.addTarget(self, action: #selector(handlePulltoRequest), for: .valueChanged)
			mainView.buttonAddAddress.addTarget(self, action: #selector(handleAddAddressButton), for: .touchUpInside)
            mainView.emptyView.buttonAddAddress.addTarget(self, action: #selector(handleAddAddressButton), for: .touchUpInside)
		}
		
	}
	
	@objc private func handleAddAddressButton() {
		presenter.routeToAddAddress(isCheckout: checkout)
	}
	
	@objc private func handlePulltoRequest() {
		if checkout {
			self.mainViewCheckout.refreshControl.endRefreshing()
			self.mainViewCheckout.searchBar.text = ""
			presenter.fetchAddress()
		} else {
			self.mainView.refreshControl.endRefreshing()
			self.mainView.searchBar.text = ""
			presenter.fetchAddress()
		}
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	func createObservers(){
		NotificationCenter.default.addObserver(self, selector: #selector(updateList), name: addressNotificationKey, object: nil)
    }
	
	@objc
	func updateList(){
		presenter.fetchAddress()
	}
}


extension AddressController : UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		if checkout {
			self.mainViewCheckout.searchBar.rx.text
				.orEmpty
				.distinctUntilChanged()
				.bind(to: self.presenter.searchValue)
				.disposed(by: self.disposeBag)
			self.presenter.isEmptySearch.bind { [weak self] (isEmpty) in
				if let empty = isEmpty {
					if empty {
						self?.mainViewCheckout.searchNoData(query: self?.mainView.searchBar.text ?? "")
					} else {
						self?.mainViewCheckout.searchHasData()
					}
				}
			}.disposed(by: self.disposeBag)
		} else {
			self.mainView.searchBar.rx.text
				.orEmpty
				.distinctUntilChanged()
				.bind(to: self.presenter.searchValue)
				.disposed(by: self.disposeBag)
			
			self.presenter.isEmptySearch.bind { [weak self] (isEmpty) in
				if let empty = isEmpty {
					if empty {
						self?.mainView.searchNoData(query: self?.mainView.searchBar.text ?? "")
					} else {
						self?.mainView.searchHasData()
					}
				}
			}.disposed(by: self.disposeBag)
		}
	}
}
