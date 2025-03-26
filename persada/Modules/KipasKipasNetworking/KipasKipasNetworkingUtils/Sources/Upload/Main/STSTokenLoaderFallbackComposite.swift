//
//  STSTokenLoaderFallbackComposite.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation

class STSTokenLoaderFallbackComposite: STSTokenLoader {
    private let primary: STSTokenLoader
    private let fallback: STSTokenLoader
    
    init(primary: STSTokenLoader, fallback: STSTokenLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(request: STSTokenLoaderRequest, completion: @escaping (STSTokenLoader.Result) -> Void) {
        primary.load(request: request, completion: { [weak self] result in
            switch result {
            case .success:
                completion(result)
            case .failure:
                self?.fallback.load(request: request, completion: completion)
            }
        })
    }
}
