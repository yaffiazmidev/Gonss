//
//  OTPMethodOptionPresenter.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/01/23.
//

import UIKit

protocol IOTPMethodOptionPresenter {
    func presentWhatsappOTP(item: AuthOTPItem)
    func presentWhatsappOTPError(item: AuthOTPItem)
    func presentSmsOTP(item: AuthOTPItem)
    func presentSmsOTPError(item: AuthOTPItem)
}

class OTPMethodOptionPresenter: IOTPMethodOptionPresenter {
	weak var controller: IOTPMethodOptionViewController?
	
	init(controller: IOTPMethodOptionViewController) {
		self.controller = controller
	}
    
    func presentWhatsappOTP(item: AuthOTPItem) {
        controller?.displayWhatsappOTP(item: item)
    }
    
    func presentWhatsappOTPError(item: AuthOTPItem) {
        controller?.displayErrorWhatsappOTP(item: item)
    }
    
    func presentSmsOTP(item: AuthOTPItem) {
        controller?.displaySmsOTP(item: item)
    }
    
    func presentSmsOTPError(item: AuthOTPItem) {
        controller?.displayErrorSmsOTP(item: item)
    }
}
