//
//  STSTokenSaver.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

public protocol STSTokenStore {
    typealias SaveItemCompletion = (Swift.Result<Void, Error>) -> Void
    typealias LoadItemCompletion = (Swift.Result<STSTokenItem, Error>) -> Void
    
    func save(key: String, stsToken: STSTokenItem, completion: @escaping SaveItemCompletion)
    
    func load(key: String, completion: @escaping LoadItemCompletion)
    
    func remove(key: String)
}
