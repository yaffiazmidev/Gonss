//
//  MyStoreAddressLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

struct MyStoreAddressLoaderRequest{
    let type: String
    
    init(type: String){
        self.type = type
    }
}
protocol MyStoreAddressLoader {
    typealias Result = Swift.Result<[MyStoreAddress], Error>

    func load(request: MyStoreAddressLoaderRequest, completion: @escaping (Result) -> Void)
}
