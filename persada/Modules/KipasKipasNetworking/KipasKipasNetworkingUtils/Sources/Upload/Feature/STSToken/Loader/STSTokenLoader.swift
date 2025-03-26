//
//  STSTokenLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

public protocol STSTokenLoader {
    typealias Result = Swift.Result<STSTokenItem, Error>
    
    func load(request: STSTokenLoaderRequest, completion: @escaping (Result) -> Void)
}
