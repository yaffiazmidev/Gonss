//
//  NSError+Extensions.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking

extension Error {
    func getErrorMessage() -> String {
        if let error = self as? KKNetworkError {
            switch error {
            case .connectivity:
                return "Gagal menghubungkan ke server"
            case .invalidData:
                return "Gagal memuat data"
            case .responseFailure(let error):
                return "Gagal memuat data\n\(error.message)"
            default:
                return error.localizedDescription
            }
        }
        
        return self.localizedDescription
    }
}
