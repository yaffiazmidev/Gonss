//
//  AddressEndpoint.swift
//  KipasKipas
//
//  Created by movan on 11/08/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum AddressEndpoint {
	case address(type: String)
	case province
	case city(id: String)
	case subdistrict(id: String)
	case postalCode(id: String)
	case removeAddress(id: String)
	case editAddress(id: String, address: Address)
	case addressDelivery
	case createAddress(address: Address)
	case searchAddressBuyer(query : String)
	case searchAddressSeller(query : String)
    case getAddressDelivery(accountID : String)
}
//{{server-rest-api}}/areas/village?id={{sub-district-id}}
extension AddressEndpoint: EndpointType {
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
		case .address:
			return "/addresses/account"
		case .city(_):
			return "/areas/city"
		case .province:
			return "/areas/province"
		case .subdistrict(_):
			return "/areas/sub_district"
		case .removeAddress(let id), .editAddress(let id, _):
			return "/addresses/\(id)"
		case .createAddress:
			return "/addresses"
			case .addressDelivery:
			return "/addresses/delivery"
		case .searchAddressBuyer(query: _):
			return "/addresses/buyer/search"
		case .searchAddressSeller(query: _):
			return "/addresses/seller/search"
		case .postalCode:
			return "/areas/village"
        case .getAddressDelivery(let accountID):
            return "/addresses/delivery/\(accountID)"
        }
	}
	
	var method: HTTPMethod {
		switch self {
		case .removeAddress(_):
			return .delete
		case .editAddress(_, _):
			return .put
		case .createAddress:
			return .post
		default:
			return .get
		}
	}
	
	var header: [String : String] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type": "application/json"
		]
	}
	
	var parameter: [String : Any] {
		switch self {
		case .city(let id), .subdistrict(let id), .postalCode(let id):
			return [
				"id" : "\(id)",
				"size" : "50"
			]
		case .removeAddress(let id):
			return [
				"id" : "\(id)"
			]
		case .province:
			return [
				"size" : "50"
			]
		case .address(let type):
			return [
				"type": type
			]
		case .createAddress(let address):
			return address.toDictionary
		case .editAddress( _, let address):
			return address.toDictionary
		case .searchAddressBuyer(let query), .searchAddressSeller(let query):
			return [
				"searchValue" : "\(query)"
			]
		default:
			return [
				"Authorization" : "Bearer \(getToken() ?? "")",
				"Content-Type": "application/json"
			]
		}
	}
	
}

