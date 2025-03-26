//
//  MidtransViewModel.swift
//  KipasKipas
//
//  Created by kuh on 13/02/21.
//  Copyright © 2021 Koanba All rights reserved.
//

import Foundation

class MidtransViewModel: BaseControllerViewModel {
    var onComplete: () -> Void = {}
    var onCancel: () -> Void = {}
    var onError: (String) -> Void = {_ in}
    var urlString: String = ""
}
