//
//  EditAddressPresenter.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit
import GoogleMaps

let addressNotificationKey = Notification.Name(rawValue: "com.kipaskipas.address.notif")
let kurirNotificationKey = Notification.Name(rawValue: "kurirNotificationKey")

final class EditAddressPresenter {
    
    private let interactorAdd = AddressInteractor()
	
	//input
	let name = PublishSubject<String>()
	let alamat = PublishSubject<String>()
	let nomorTelepon = PublishSubject<String>()
    let isLocationSelected = BehaviorRelay<Bool>(value: false)
	
	var isDefault : Bool?
	var isDelivery : Bool?
	
	var isSeller : AddressFetchType!
	
	var idProvinsi : String = ""
	var idCity : String = ""
	var idSubDistrict : String = ""
	var postalCode : String = ""
	var type : AddressTypeEnum!
    
    var lat : String = ""
    var long : String = ""
    
    var selectedAddress : String!
	
	let errorRelay = BehaviorRelay<Error?>(value: nil)
	let namaAlamatRelay = BehaviorRelay<[String]>(value: [NamaAlamatEnum.rumah.rawValue, NamaAlamatEnum.kantor.rawValue, NamaAlamatEnum.gudang.rawValue])
	var address : Address?
	
	private let interactor : EditAddressInteractor!
	private let disposeBag = DisposeBag()
	private let router : EditAddressRouter!
	
	init(router: EditAddressRouter, interactor: EditAddressInteractor) {
		self.interactor = interactor
		self.router = router
		self.isSeller = interactor.isSeller
		self.address = interactor.address
		self.type = interactor.type
        
        if let idProvinsi = address?.provinceId, let idCity = address?.cityId, let idSubdistrict = address?.subDistrictId {
            self.idProvinsi = idProvinsi
            self.idCity = idCity
            self.idSubDistrict = idSubdistrict
        }
        if let lat = address?.latitude, let long = address?.longitude {
            latLong(lat: lat, long: long)
            self.lat = lat
            self.long = long
        }
	}
	
	func removeAddress() {
		if let id = interactor.address?.id {
			interactor.removeAddress(id: id).subscribe { [weak self] (removeResponse) in
				self?.router.dismissEditAddressScene()
				NotificationCenter.default.post(name: addressNotificationKey, object: nil)
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)
		}
	}
	
	func updateAddress(address: Address){
		if let id = interactor.address?.id {
			interactor.updateAddress(id: id, address: address).subscribe { [weak self] (defaultResponse) in
				self?.router.dismissEditAddressScene()
				NotificationCenter.default.post(name: addressNotificationKey, object: nil)
			
			} onError: { [weak self] (error) in
				self?.errorRelay.accept(error)
			}.disposed(by: disposeBag)

		}
	}
	
    func addAddress(address: Address, isFirstAdded: Bool, isCheckout: Bool = false) {
		interactor.addAddress(address: address).subscribe { [weak self] (response) in
            
			NotificationCenter.default.post(name: addressNotificationKey, object: nil)
            
            if isFirstAdded && isCheckout {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5, execute: {
                    self?.fetchAddress(address: address, isFirstAdded: isFirstAdded, isCheckout: isCheckout)
                })
            } else if isFirstAdded {
                    NotificationCenter.default.post(name: kurirNotificationKey, object: nil)
                    self?.router.dismissEditAddressScene(address: address, isFirstAdded: isFirstAdded, isCheckout: isCheckout)
            } else {
                self?.router.dismissEditAddressScene(address: address, isFirstAdded: isFirstAdded, isCheckout: isCheckout)
            }
		} onError: { [weak self] (error) in
			self?.errorRelay.accept(error)
		}.disposed(by: disposeBag)
	}
    
    func fetchAddress(address: Address, isFirstAdded: Bool, isCheckout: Bool = false) {
        interactorAdd.addressResponse(type: "BUYER_ADDRESS").subscribe { [weak self] (result) in
            var add = address
            let eachAdd = result.data?.first
            if let id = eachAdd?.id {
                add.id = id
                self?.router.dismissEditAddressScene(address: add, isFirstAdded: isFirstAdded, isCheckout: isCheckout)
            } else {
                print("Unknown error address")
            }
        } onError: { [weak self] (error) in
            self?.errorRelay.accept(error)
        }.disposed(by: disposeBag)
    }
	
	
	func isDataAlreadyFilled() -> Observable<Bool> {
        return Observable.combineLatest(name.asObservable(), alamat.asObservable(), nomorTelepon.asObservable()).map { name, alamat, nomorTelepon in
			let shouldZero = nomorTelepon.prefix(2) == "08"
            let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            let alamat = alamat.replacingOccurrences(of: StringEnum.alamatPlaceholder.rawValue, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            let nomorTelepon = nomorTelepon.trimmingCharacters(in: .whitespacesAndNewlines)
            return !name.isEmpty && !alamat.isEmpty && !nomorTelepon.isEmpty && shouldZero
		}
	}
	
	func chooseProvince(){
		router.chooseProvince(.province)
	}
	
	func chooseCity(){
		router.chooseCity(idProvinsi, .city)
	}
	
	func chooseSubdistrict(){
		router.chooseSubdistrict(idCity, .subdistrict)
	}
	
	func choosePostalcode(){
		router.choosePostalcode(idSubDistrict, .postalCode)
	}
	
    func chooseLocation(){
        router.chooseLocation()
    }
    
	private func createAddressParameter() -> Address {
		return Address(city: getValueString(subject: name), cityId: address?.cityId ?? "", detail: getValueString(subject: alamat), isDefault: isDefault ?? false, isDelivery: isDelivery ?? false, label: "", latitude: "", longitude: "", phoneNumber: getValueString(subject: nomorTelepon), postalCode: getValueString(subject: name), province: getValueString(subject: name), provinceId: address?.provinceId ?? "", receiverName: getValueString(subject: name), senderName: getValueString(subject: name), subDistrict: getValueString(subject: name), subDistrictId: address?.subDistrictId ?? "")
	}
	
	func getValueString(subject: PublishSubject<String>) -> String {
		let behavior = BehaviorRelay<String>(value: "")
		subject.asObservable().bind(to: behavior).disposed(by: disposeBag)
		return behavior.value
	}
	
	
    func latLong(lat: String,long: String) {
        
        let geoCoder = CLGeocoder()
        var address = ""
        
        let location = CLLocation(latitude: Double(lat) ?? 0.0 , longitude: Double(long) ?? 0.0)
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            if let error = error {
                print("Error GeoLocation \(error)")
            }
            
            if let placeMark = placemarks?[0] {
                
                if let thoroughfare = placeMark.thoroughfare {
                    address = "\(thoroughfare) "
                }
                if let subThoroughfare = placeMark.subThoroughfare {
                    address = "\(address)No. \(subThoroughfare) "
                }
                if let locality = placeMark.locality {
                    address = "\(address)\(locality) "
                }
                if let subLocality = placeMark.subLocality {
                    address = "\(address)\(subLocality) "
                }
                if let postalCode = placeMark.postalCode {
                    address = "\(address)\(postalCode) "
                }
                if let administrativeArea = placeMark.administrativeArea {
                    address = "\(address)\(administrativeArea) "
                }
                if let subAdministrativeArea = placeMark.subAdministrativeArea {
                    address = "\(address)\(subAdministrativeArea) "
                }
                if let country = placeMark.country {
                    address = "\(address)\(country)"
                }
                
                self.selectedAddress = address
            }
        })
    }
}


enum NamaAlamatEnum : String{
	case rumah = "Rumah"
	case kantor = "Kantor"
	case gudang = "Gudang"
}
