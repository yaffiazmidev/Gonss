//
//  ResellerProductStop.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 03/03/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

//Untuk stop product sebagai product reseller
struct ResellerProductStopperRequest: Equatable, Encodable {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

protocol ResellerProductStopper{
    typealias Result = Swift.Result<Void, Error>
    
    func stop(request: ResellerProductStopperRequest, completion: @escaping (Result) -> Void)
}
