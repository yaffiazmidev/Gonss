//
//  AuthEndpoint.swift
//  Persada
//
//  Created by Muhammad Noor on 22/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum AuthEndpoint {
	case login(username: String, password: String)
	case logout(token: String)
    case requestOTP(phone: String, platform: String)
    case verifyOTP(code: String, phoneNumber: String, platform: String)
    case inputUser(firstName: String, phone: String, password: String, email: String, photo: String, username: String, otp: String, birthDate: String, gender: String, deviceId: String)
	case showChannels
	case followChannels
	case showArtists
	case followArtist
	case searchArtists(name: String)
	case requstForgotPassword(phoneNumber: String, platform: String)
	case forgotPasswordVerifyOTP(code: String, phoneNumber: String, platform: String)
	case forgotPassword(id: String, phoneNumber: String, otpCode: String, newPassword: String)
    case refreshToken(refreshToken: String)
}

extension AuthEndpoint: EndpointType {
	var baseUrl: URL {
		return URL(string: APIConstants.baseURL)!
	}
	
	var path: String {
		switch self {
			case .login(_, _):
				return "/auth/login"
			case .requestOTP(_, _):
				return "/auth/otp"
			case .verifyOTP(_, _, _):
				return "/auth/otp/verification"
			case .inputUser:
				return "/auth/registers"
			case .showChannels:
				return "auth/registers/channels"
			case .followChannels:
				return "/auth/registers/channels/follows"
			case .showArtists:
				return "/auth/registers/accounts/seleb"
			case .followArtist:
				return "/auth/registers/accounts/follows"
			case .searchArtists(_):
				return "auth/registers/accounts/search"
			case .requstForgotPassword(phoneNumber: _):
				return "/auth/forgot-password/request"
			case .forgotPasswordVerifyOTP(_, _, _):
				return "/auth/forgot-password/verify/otp"
			case .forgotPassword(id: _, phoneNumber: _, otpCode: _, newPassword: _):
				return "/auth/forgot-password"
			case .logout(token: _):
				return "/auth/logout"
            case .refreshToken(refreshToken: _):
                return "/auth/refresh_token"
		}
	}
	
	var method: HTTPMethod {
		switch self {
			case .followChannels, .followArtist:
				return .patch
        case .showChannels, .showArtists, .searchArtists(_), .refreshToken(_):
				return .get
			default:
				return .post
		}
	}
	
	var body: [String: Any] {
		switch self {
			case .login(let username, let password):
				return [
					"username" : username,
					"password" : password,
                    "deviceId" : getDeviceId()
                ]
			case .requestOTP(let phone, let platform):
				return [
					"phoneNumber" : phone,
                    "platform": platform
			]
			case .verifyOTP(let code, let phoneNumber, let platform):
				return [
					"code" : code,
					"phoneNumber" : phoneNumber,
                    "platform": platform
			]
			case let .inputUser(firstName, phone, password, email, photo, username, otp, birthDate, gender , deviceId):
				return [
					"name" : firstName,
					"mobile" : phone,
					"password" : password,
					"photo" : photo,
					"username" : username,
					"otpCode" : otp,
                    "gender" : gender,
                    "birthDate" : birthDate,
                    "deviceId" : deviceId,
                    "email" : email
			]
			case .showChannels, .followChannels, .showArtists, .followArtist, .searchArtists(_), .logout(token: _):
				return [:]
			
        case .requstForgotPassword(let phoneNumber, let platform):
				return [
					"key": phoneNumber,
                    "platform": platform
                    
			]
			case .forgotPasswordVerifyOTP(let code, let phoneNumber, let platform):
				return [
					"code":code,
					"phoneNumber": phoneNumber,
                    "platform": platform
			]
			case .forgotPassword(let id, let phoneNumber, let otpCode, let password):
				return [
					"id": id,
					"key": phoneNumber,
					"otpCode": otpCode,
					"newPassword": password
			]
            default:
                return [:]
		}
	}
	
	var header: [String : Any] {
		return [
			"Authorization" : "Bearer \(getToken() ?? "")",
			"Content-Type":"application/json"
		]
	}
	
	var parameter: [String : Any] {
		switch self {
			case .logout(let token):
				return [
					"token" : token
			]
			case .showChannels, .showArtists:
				return [
					"page" : "0",
					"size" : "6",
					"sort" : "name,asc"
			]
			case .searchArtists(let name):
				return [
					"type" : "seleb",
					"name" : name,
					"page" : "0",
					"size" : "6",
					"sort" : "name,asc"
			]
            case .refreshToken(let refreshToken):
                return [
                    "refresh_token" : refreshToken,
                    "grant_type"    : "refresh_token"
                ]
			default:
				return [:]
		}
	}
	
}
