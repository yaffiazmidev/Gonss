//
//  NewsPortalLoaderFallbackComposite.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/02/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

class NewsPortalLoaderFallbackComposite: NewsPortalLoader {
    private var data: [NewsPortalData]? = nil
    private let fallback: NewsPortalLoader
    
    typealias Result = NewsPortalLoader.Result
    
    init(fallback: NewsPortalLoader) {
        self.fallback = fallback
    }
    
    func load(completion: @escaping (Result) -> Void) {
        if let data = data {
            completion(.success(data))
            return
        }
        
        fallback.load { [weak self] result in
            switch result {
            case .success(let data):
                self?.data = data
                completion(.success(data))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
}
