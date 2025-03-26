//
//  BaseControllerViewModel.swift
//  KipasKipas
//
//  Created by kuh on 05/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

class BaseControllerViewModel {
    @Published var isLoading: Bool = false

    func startLoading() {
        isLoading = true
    }

    func stopLoading() {
        isLoading = false
    }
}
