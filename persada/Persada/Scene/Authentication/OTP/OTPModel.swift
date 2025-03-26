//
//  OTPModel.swift
//  Persada
//
//  Created by monggo pesen 3 on 15/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.



import Foundation

enum OTPModel {
  
  enum Request {
    case OTP(number: String)
    case verifyOTP(code: String, phoneNumber: String)
  }
  
  enum Response {
    case OTP(data: ResultData<DefaultResponse>)
    case verifyOTP(data: ResultData<VerifyOTP>)
	case verifyOTPPassword(data: ResultData<VerifyForgotPassword>)
  }
  
  enum ViewModel {
    case OTP(viewModelData: ResultData<DefaultResponse>)
    case verifyOTP(viewModelData: ResultData<VerifyOTP>)
	case verifyOTPPassword(viewModelData: ResultData<VerifyForgotPassword>)
  }
  
  enum Route {
    case dismissOTPScene
		case inputUserScene(phoneNumber: String, otpCode: String)
      case navigateToResetPassword(id: String, phoneNumber: String, otp: String, otpPlatform: String)
	
  }
  
  struct DataSource: DataSourceable {
    var number: String
	var isFromForgotPassword: Bool = false
  }
}
