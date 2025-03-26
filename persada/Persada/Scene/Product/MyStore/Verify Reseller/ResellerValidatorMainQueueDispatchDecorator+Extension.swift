//
//  ResellerValidatorMainQueueDispatchDecorator+Extension.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

extension MainQueueDispatchDecorator: ResellerValidator where T == ResellerValidator {
    func verify(completion: @escaping (ResellerValidator.Result) -> Void) {
        decoratee.verify { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
 
