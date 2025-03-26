//
//  AllowCallInteractorAdapter.swift
//  KipasKipasDirectMessageUI
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/02/24.
//

import Foundation
import Combine
import KipasKipasDirectMessage

final class AllowCallInteractorAdapter {
    
    typealias AllowCallResult = Swift.Result<AllowCall, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (AllowCallParam) -> AllowCallLoader
    
    init(loader: @escaping (AllowCallParam) -> AllowCallLoader) {
        self.loader = loader
    }
    
    func load(by accountId: String, completion: @escaping (AllowCallResult) -> Void) {
        cancellable = loader(AllowCallParam(targetAccountId: accountId))
            .dispatchOnMainQueue()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }, receiveValue: { response in
                completion(.success(response.data))
            })
    }
}
