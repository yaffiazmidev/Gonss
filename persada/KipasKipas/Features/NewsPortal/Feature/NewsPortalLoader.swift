//
//  NewsPortalLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

protocol NewsPortalLoader {
    typealias Result = Swift.Result<[NewsPortalData], Error>
    
    func load(completion: @escaping (Result) -> Void)
}

extension MainQueueDispatchDecorator: NewsPortalLoader where T == NewsPortalLoader {
    func load(completion: @escaping (NewsPortalLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
