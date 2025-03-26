//
//  AddressPreference.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 01/04/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class AddressPreference : NSObject {
	private static let selectedAddressIDKey = "selectedAddressIDKey"
	private static let addressKey = "addressKey"
	private static let isAlamatUtamaKey = "selectedAddressIDKey"
	
	static let instance = AddressPreference()
	private let userDefaults: UserDefaults
	
	override init() {
		userDefaults = UserDefaults.standard
	}
	
	init(userDefaults: UserDefaults) {
		self.userDefaults = userDefaults
	}
	
	var selectedAddressID: String? {
				 get {
						 return userDefaults.string(forKey: AddressPreference.selectedAddressIDKey)
				 }
				 set(newValue) {
						 if let value = newValue {
								 userDefaults.set(value, forKey: AddressPreference.selectedAddressIDKey)
						 }else {
								 userDefaults.removeObject(forKey:AddressPreference.selectedAddressIDKey)
						 }
				 }
		 }
	
	var address: String? {
				 get {
						 return userDefaults.string(forKey: AddressPreference.addressKey)
				 }
				 set(newValue) {
						 if let value = newValue {
								 userDefaults.set(value, forKey: AddressPreference.addressKey)
						 }else {
								 userDefaults.removeObject(forKey:AddressPreference.addressKey)
						 }
				 }
		 }
	
	var isAlamatUtama: Bool {
				get {
						return userDefaults.bool(forKey: AddressPreference.isAlamatUtamaKey)
				}
				set (newValue) {
						userDefaults.set(newValue, forKey: AddressPreference.isAlamatUtamaKey)
				}
		}
}
