//
//  MyStoreBalanceLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

protocol MyStoreBalanceLoader {
    typealias Result = Swift.Result<MyStoreBalance, Error>

    func load(completion: @escaping (Result) -> Void)
}
