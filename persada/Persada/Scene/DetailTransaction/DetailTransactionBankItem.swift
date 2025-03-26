//
//  DetailTransactionBankItem.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

enum DetailTransactionBankItem: String {
    case bca = "bca"
//    case ovo = "ovo"
    case mandiri = "mandiri"
    case permata = "permata"
//    case dana = "dana"
    case bni = "bni"
    case bri = "bri"
    case undifined
//    case gopay = "gopay"
    
    var icon: String {
        switch self {
        case .bca: return .get(.iconbca)
//        case .ovo: return .get(.icon)
        case .mandiri: return .get(.iconMandiriBank)
        case .permata: return .get(.iconPermataBank)
//        case .dana: return .get(.iconDana)
        case .bni: return .get(.iconBNIBank)
        case .bri: return .get(.iconBRIBank)
//        case .gopay: return .get(.icon)
        default: return .get(.Kipaskipas)
        }
    }
}
