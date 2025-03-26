//
//  ResellerConfirmProductDelegate.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 07/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol UserSellerControllerDelegate {
    func didRequestUserSeller(request: UserSellerRequest)
}

protocol ResellerConfirmProductControllerDelegate {
    func didResellerConfirmProduct(request: ResellerProductConfirmRequest)
}

protocol ResellerProductControllerDelegate {
    func didRequestResellerProduct(request: ResellerProductRequest)
}

typealias ResellerConfirmProductDelegate = UserSellerControllerDelegate & ResellerConfirmProductControllerDelegate & ResellerProductControllerDelegate & ResellerValidatorControllerDelegate

