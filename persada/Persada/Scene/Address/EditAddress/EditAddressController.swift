//
//  EditAddressController.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


final class EditAddressController: UIViewController, AlertDisplayer{
    
	
	private let mainView: EditAddressView
	private let mainAddView: AddAddressView
	private var presenter: EditAddressPresenter!
	private let disposeBag = DisposeBag()
	private var isFilled = false
	private var isSeller : AddressFetchType
    
    var isFromCheckout = false
    var isFirstAdded = false
    var isMultipleAddress = false
	
	init(mainView: EditAddressView, address: Address?, type : AddressTypeEnum, isSeller : AddressFetchType, _ isMultipleAddress: Bool) {
		self.mainView = mainView
		self.mainAddView = AddAddressView()
		self.isSeller = isSeller
		if self.isSeller == .seller {
			self.mainView.updateToSellerView()
		}
        self.mainView.updateIsMultipleAddress(isMultipleAddress)
		super.init(nibName: nil, bundle: nil)
		let interactor = EditAddressInteractor(address: address, type: type, isSeller: isSeller)
		let router = EditAddressRouter(self)
		presenter = EditAddressPresenter(router: router, interactor: interactor)
		self.presenter.address = address
        bindNavigationBar(.get(.editAlamatToko))
	}
	
	init(mainAddView: AddAddressView, address: Address?, type : AddressTypeEnum, isSeller : AddressFetchType) {
		self.mainAddView = mainAddView
		self.mainView = EditAddressView()
		self.isSeller = isSeller
		if self.isSeller == .seller {
			self.mainAddView.updateToSellerView()
		}
		super.init(nibName: nil, bundle: nil)
		let interactor = EditAddressInteractor(address: address, type: type, isSeller: isSeller)
		let router = EditAddressRouter(self)
		presenter = EditAddressPresenter(router: router, interactor: interactor)
		self.presenter.address = address
        let validTitle = presenter.isSeller == .seller ? String.get(.tambahAlamatPengiriman) : String.get(.tambahAlamat)
        bindNavigationBar(validTitle)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		createErrorObserver()
	}
	
	
	func createErrorObserver(){
		presenter.errorRelay.bind { (error) in
            print("error tambah", error.debugDescription)
            self.mainAddView.buttonAddAddress.isEnabled = false
			if let error = error?.localizedDescription {
				let action = UIAlertAction(title: StringEnum.ok.rawValue, style: .default)
				self.displayAlert(with: StringEnum.error.rawValue, message: error, actions: [action])
			}
		}.disposed(by: disposeBag)
	}
	
	func createViewObserverAdd(){
		presenter.isDataAlreadyFilled().bind { (isFilled) in
			self.isFilled = isFilled
            if isFilled && self.mainAddView.provinceItemView.textFieldIsEmpty() && self.mainAddView.cityItemView.textFieldIsEmpty() && self.mainAddView.subdistrictItemView.textFieldIsEmpty() && self.mainAddView.codePostItemView.textFieldIsEmpty() {
                self.presenter.isLocationSelected.bind { (selected) in
                    if selected && isFilled {
                        self.mainAddView.enableButton()
                    } else {
                        self.mainView.disableButton()
                    }
                }.disposed(by: self.disposeBag)
			} else {
				self.mainAddView.disableButton()
			}
		}.disposed(by: disposeBag)
		mainAddView.nameItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.name).disposed(by: disposeBag)
		mainAddView.addressItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.alamat).disposed(by: disposeBag)
		mainAddView.phoneItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.nomorTelepon).disposed(by: disposeBag)
		
		presenter.namaAlamatRelay.asObservable().bind(to: mainAddView.namaAlamatCollectionView.rx.items(cellIdentifier: String.get(.cellID), cellType: AddressNameItemCell.self)) {
			index, data, cell in
			cell.setUpCell(category: data)
			DispatchQueue.main.async {
				let indexPath = IndexPath(item: 0, section: 0)
				self.mainAddView.namaAlamatCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
				self.mainAddView.addressLabelItemView.nameTextField.text = "Rumah"
			}
			
		}.disposed(by: disposeBag)
		
		mainAddView.namaAlamatCollectionView.rx.modelSelected(String.self).subscribe { (index) in
			switch index.element {
			case "Rumah":
				self.mainAddView.addressLabelItemView.nameTextField.text = "Rumah"
			case "Kantor":
				self.mainAddView.addressLabelItemView.nameTextField.text = "Kantor"
			case "Gudang":
				self.mainAddView.addressLabelItemView.nameTextField.text = "Gudang"
			default:
				break
			}
		}.disposed(by: disposeBag)
        
        mainAddView.nameItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainAddView.nameHeightAnchor.constant = text.isEmpty ? 100 : 80
            if text.isEmpty {
                self.mainAddView.nameItemView.showError("Nama penerima tidak boleh kosong")
            } else {
                self.mainAddView.nameItemView.hideError()
            }
        }
        
        mainAddView.addressItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainAddView.addressHeightAnchor.constant = text.isEmpty ? 160 : 140
            if text.isEmpty {
                self.mainAddView.addressItemView.showError("Deskripsi alamat tidak boleh kosong")
            } else {
                self.mainAddView.addressItemView.hideError()
            }
        }
        
        mainAddView.phoneItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainAddView.nameHeightAnchor.constant = text.isEmpty ? 100 : 80
            if text.isEmpty {
                self.mainAddView.phoneItemView.showError("Nomor telepon tidak boleh kosong")
            } else {
                self.mainAddView.phoneItemView.hideError()
            }
        }
	}
	
	func createViewObserverEdit(){
		presenter.isDataAlreadyFilled().bind { (isFilled) in
			self.isFilled = isFilled
			if isFilled && self.mainView.provinceItemView.textFieldIsEmpty() && self.mainView.cityItemView.textFieldIsEmpty() && self.mainView.subdistrictItemView.textFieldIsEmpty() && self.mainView.codePostItemView.textFieldIsEmpty()  {
                self.presenter.isLocationSelected.bind { (selected) in
                    if selected && isFilled {
                        print("LOHE \(selected)")
                        self.mainView.enableButton()
                    } else {
                        self.mainView.disableButton()
                    }
                }.disposed(by: self.disposeBag)
			} else {
				self.mainView.disableButton()
			}
		}.disposed(by: disposeBag)
		mainView.nameItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.name).disposed(by: disposeBag)
		mainView.addressItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.alamat).disposed(by: disposeBag)
		mainView.phoneItemView.nameTextField.rx.text.map{ $0 ?? "" }.bind(to: presenter.nomorTelepon).disposed(by: disposeBag)
		
		presenter.namaAlamatRelay.asObservable().bind(to: mainView.namaAlamatCollectionView.rx.items(cellIdentifier: String.get(.cellID), cellType: AddressNameItemCell.self)) {
			index, data, cell in
			cell.setUpCell(category: data)
		}.disposed(by: disposeBag)
		
		mainView.namaAlamatCollectionView.rx.modelSelected(String.self).subscribe { (index) in
			switch index.element {
			case NamaAlamatEnum.rumah.rawValue:
				self.mainView.addressLabelItemView.nameTextField.text = "Rumah"
			case NamaAlamatEnum.kantor.rawValue:
				self.mainView.addressLabelItemView.nameTextField.text = "Kantor"
			case NamaAlamatEnum.gudang.rawValue:
				self.mainView.addressLabelItemView.nameTextField.text = "Gudang"
			default:
				break
			}
		}.disposed(by: disposeBag)
		
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let address = self.presenter.selectedAddress {
                if !address.isEmpty {
                    self.mainView.updateMaps(address: address)
                    self.presenter.isLocationSelected.accept(true)
                }
            }
        }
        
        mainView.nameItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainView.nameHeightAnchor.constant = text.isEmpty ? 100 : 80
            if text.isEmpty {
                self.mainView.nameItemView.showError("Nama penerima tidak boleh kosong")
            } else {
                self.mainView.nameItemView.hideError()
            }
        }
        
        mainView.addressItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainView.addressHeightAnchor.constant = text.isEmpty ? 160 : 140
            if text.isEmpty {
                self.mainView.addressItemView.showError("Deskripsi alamat tidak boleh kosong")
            } else {
                self.mainView.addressItemView.hideError()
            }
        }
        
        mainView.phoneItemView.handleTextFieldEditingChanged = { textField in
            let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.mainView.nameHeightAnchor.constant = text.isEmpty ? 100 : 80
            if text.isEmpty {
                self.mainView.phoneItemView.showError("Nomor telepon tidak boleh kosong")
            } else {
                self.mainView.phoneItemView.hideError()
            }
        }
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = true
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	fileprivate func layoutEditAddress() {
		view = mainView
		mainView.backgroundColor = .white
		
		self.mainView.data = presenter.address
		
		
		let gestureProvince = UITapGestureRecognizer()
		let gestureCity = UITapGestureRecognizer()
		let gestureSubdistrict = UITapGestureRecognizer()
		let gesturePostalCode = UITapGestureRecognizer()
        let gesturePinPoint = UITapGestureRecognizer()
		mainView.codePostItemView.nameTextField.addGestureRecognizer(gesturePostalCode)
		mainView.provinceItemView.nameTextField.addGestureRecognizer(gestureProvince)
		mainView.cityItemView.nameTextField.addGestureRecognizer(gestureCity)
		mainView.subdistrictItemView.nameTextField.addGestureRecognizer(gestureSubdistrict)
		mainView.buttonRemoveAddress.addTarget(self, action: #selector(handleRemoveAddress), for: .touchUpInside)
		mainView.buttonSaveAddress.addTarget(self, action: #selector(handleSaveAddress), for: .touchUpInside)
        mainView.viewMaps.addGestureRecognizer(gesturePinPoint)
		
		createViewObserverEdit()
        bindGesture(gestureProvince: gestureProvince, gestureCity: gestureCity, gestureSubdistrict: gestureSubdistrict, gesturePostalCode: gesturePostalCode, gesturePinPoint: gesturePinPoint)
	}
	
	fileprivate func layoutAddAddress() {
		view = mainAddView
		mainAddView.backgroundColor = .white
		
		let gestureProvince = UITapGestureRecognizer()
		let gestureCity = UITapGestureRecognizer()
		let gestureSubdistrict = UITapGestureRecognizer()
		let gesturePostalCode = UITapGestureRecognizer()
        let gesturePinPoint = UITapGestureRecognizer()
		mainAddView.provinceItemView.nameTextField.addGestureRecognizer(gestureProvince)
		mainAddView.cityItemView.nameTextField.addGestureRecognizer(gestureCity)
		mainAddView.subdistrictItemView.nameTextField.addGestureRecognizer(gestureSubdistrict)
		mainAddView.codePostItemView.nameTextField.addGestureRecognizer(gesturePostalCode)
		mainAddView.buttonAddAddress.addTarget(self, action: #selector(handleAddAddress), for: .touchUpInside)
        mainAddView.viewMaps.addGestureRecognizer(gesturePinPoint)
		
		createViewObserverAdd()
		bindGesture(gestureProvince: gestureProvince, gestureCity: gestureCity, gestureSubdistrict: gestureSubdistrict, gesturePostalCode: gesturePostalCode, gesturePinPoint: gesturePinPoint)
	}
	
    func bindGesture(gestureProvince : UITapGestureRecognizer, gestureCity : UITapGestureRecognizer, gestureSubdistrict : UITapGestureRecognizer, gesturePostalCode : UITapGestureRecognizer, gesturePinPoint : UITapGestureRecognizer){
		gestureProvince.rx.event.bind { [weak self] (gesture) in
			self?.presenter.chooseProvince()
		}.disposed(by: disposeBag)
		gestureCity.rx.event.bind { [weak self] (gesture) in
			self?.presenter.chooseCity()
		}.disposed(by: disposeBag)
		gestureSubdistrict.rx.event.bind { [weak self] (gesutre) in
			self?.presenter.chooseSubdistrict()
		}.disposed(by: disposeBag)
		gesturePostalCode.rx.event.bind { [weak self] (gesutre) in
			self?.presenter.choosePostalcode()
		}.disposed(by: disposeBag)
        gesturePinPoint.rx.event.bind { [weak self] (gesutre) in
            self?.presenter.chooseLocation()
        }.disposed(by: disposeBag)
	}
	
	override func loadView() {
		let type = presenter.type
		if type == .edit {
			layoutEditAddress()
		} else {
			layoutAddAddress()
		}
	}
	
	@objc private func handleRemoveAddress() {
		
		let title = String.get(.warning)
		let action = UIAlertAction(title: String.get(.ok), style: .default) { [weak self] (action) in
			self?.presenter.removeAddress()
		}
		let cancel = UIAlertAction(title: String.get(.cancel), style: .cancel)
		
		self.displayAlert(with: title , message: String.get(.apakahAndaYakin), actions: [action, cancel])
	}
	
	@objc private func handleSaveAddress() {
        mainAddView.buttonAddAddress.isEnabled = false
		presenter.updateAddress(address: mainView.getAddress(provinceID: presenter.address?.provinceId ?? presenter.idProvinsi, cityID: presenter.address?.cityId ?? presenter.idCity, subDistrictID: presenter.address?.subDistrictId ?? presenter.idSubDistrict, type: isSeller, lat: presenter.lat, lng: presenter.long))
	}
	
	@objc private func handleAddAddress() {
        mainAddView.buttonAddAddress.isEnabled = false
		presenter.addAddress(address: mainAddView.getAddress(provinceID: presenter.idProvinsi, cityID: presenter.idCity, subDistrictID: presenter.idSubDistrict, type: isSeller, lat: presenter.lat, lng: presenter.long, isFirstAdded: isFirstAdded), isFirstAdded: self.isFirstAdded, isCheckout: isFromCheckout)
	}
	
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}
}


// MARK: - EditAddressViewDelegate
extension EditAddressController: UIGestureRecognizerDelegate {
	
	func back(_ data: Area, type: AreasTypeEnum) {
		var address = self.presenter.address
		switch type {
		case .province :
			address?.provinceId = data.id
			presenter.idProvinsi = data.id ?? ""
			self.presenter.address = address
			if mainView.data != nil {
				self.mainView.provinceItemView.nameTextField.text = data.name
				self.mainView.cityItemView.nameTextField.text = ""
				self.mainView.subdistrictItemView.nameTextField.text = ""
				self.mainView.codePostItemView.nameTextField.text = ""
			} else {
				self.mainAddView.provinceItemView.nameTextField.text = data.name
				self.mainAddView.cityItemView.nameTextField.text = ""
				self.mainAddView.subdistrictItemView.nameTextField.text = ""
				self.mainAddView.codePostItemView.nameTextField.text = ""
			}
			
			self.mainView.disableButton()
			
		case .city :
            mainAddView.subdistrictItemView.nameTextField.text = ""
            address?.subDistrictId = ""
            presenter.idSubDistrict = ""
            
            mainAddView.codePostItemView.nameTextField.text = ""
            address?.postalCode = data.id
            presenter.postalCode = data.id ?? ""
            
			address?.cityId = data.id
			presenter.idCity = data.id ?? ""
			self.presenter.address = address
			
			if mainView.data != nil {
				self.mainView.cityItemView.nameTextField.text = data.name
			} else {
				self.mainAddView.cityItemView.nameTextField.text = data.name
			}
			
		case .subdistrict:
            mainAddView.codePostItemView.nameTextField.text = ""
            address?.postalCode = data.id
            presenter.postalCode = data.id ?? ""
            
			address?.subDistrictId = data.id
			presenter.idSubDistrict = data.id ?? ""
			self.presenter.address = address
			
			if mainView.data != nil {
				mainView.subdistrictItemView.nameTextField.text = data.name
			} else {
				mainAddView.subdistrictItemView.nameTextField.text = data.name
			}
			
		case .postalCode:
			address?.postalCode = data.id
			presenter.postalCode = data.id ?? ""
			self.presenter.address = address
			
			if mainView.data != nil {
				mainView.codePostItemView.nameTextField.text = data.postalCode
			} else {
				mainAddView.codePostItemView.nameTextField.text = data.postalCode
			}
			if isFilled {
				self.mainView.enableButton()
			}
		}
		
	}
    
    func backFromMaps(lat : String, long : String, address : String){
        presenter.lat = lat
        presenter.long = long
        presenter.isLocationSelected.accept(true)
        
        let type = presenter.type
        if type == .edit {
            mainView.updateMaps(address: address)
        } else {
            mainAddView.updateMaps(address: address)
        }
    }
}

protocol PopoverArea: AnyObject {
	func back(_ data: Area, type: String)
}
