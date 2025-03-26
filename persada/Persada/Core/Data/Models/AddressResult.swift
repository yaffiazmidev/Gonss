//
//  AddressResult.swift
//  Persada
//
//  Created by movan on 23/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

struct AddressResult :Codable {
	
	var code : String?
	var data : [Address]?
	var message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct SingleAddressResult :Codable {

	var code : String?
	var data : Address?
	var message : String?

	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}

struct Address : Codable {
	
	var accountId : String?
	var city : String?
	var cityId : String?
//	var cityType : String?
	var detail : String?
	var id : String?
	var isDefault : Bool?
	var isDelivery : Bool?
	var label : String?
	var latitude : String?
	var longitude : String?
	var phoneNumber : String?
	var postalCode : String?
	var province : String?
	var provinceId : String?
	var receiverName : String?
	var senderName : String?
	var subDistrict : String?
	var subDistrictId : String?
	var addressType : String?
    var isAddresses: Bool?
	
	enum CodingKeys: String, CodingKey {
		case accountId = "accountId"
		case city = "city"
		case cityId = "cityId"
//		case cityType = "cityType"
		case detail = "detail"
		case id = "id"
		case isDefault = "isDefault"
		case isDelivery = "isDelivery"
		case label = "label"
		case latitude = "latitude"
		case longitude = "longitude"
		case phoneNumber = "phoneNumber"
		case postalCode = "postalCode"
		case province = "province"
		case provinceId = "provinceId"
		case receiverName = "receiverName"
		case senderName = "senderName"
		case subDistrict = "subDistrict"
		case subDistrictId = "subDistrictId"
		case addressType = "addressType"
        case isAddresses = "isAddresses"
	}
	
	var toDictionary : [String:Any] {
			let mirror = Mirror(reflecting: self)
			let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
				guard let label = label else { return nil }
				return (label, value)
			}).compactMap { $0 })
			return dict
		}
}

struct DeliveryAddress :Codable {
	
	var code : String?
	var data : Address?
	var message : String?
	
	enum CodingKeys: String, CodingKey {
		case code = "code"
		case data = "data"
		case message = "message"
	}
}


struct ParameterCourier: Codable {
	
	var productId: String?
	var addressId: String?
	var quantity: Int?
	
	enum CodingKeys: String, CodingKey {
		case productId
		case addressId
		case quantity
	}
	
}
