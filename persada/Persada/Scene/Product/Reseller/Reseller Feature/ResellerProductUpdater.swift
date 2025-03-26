//
//  ResellerProductUpdater.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 25/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct ResellerProductUpdaterRequest: Equatable, Encodable {
    let id: String
    let modal: Int
    let commission: Int
    
    init(id: String, modal: Int, commission: Int) {
        self.id = id
        self.modal = modal
        self.commission = commission
    }
}

protocol ResellerProductUpdater{
    typealias Result = Swift.Result<Void, Error>
    
    func update(request: ResellerProductUpdaterRequest, completion: @escaping (Result) -> Void)
}
