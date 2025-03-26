//
//  DonationCartOrderInteractorAdapter.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/02/24.
//

import Foundation
import Combine

public final class DonationCartOrderInteractorAdapter {
    
    public typealias DonationCartOrderResult = Swift.Result<DonationCartOrder, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (DonationCartOrderParam) -> DonationCartOrderLoader
    
    public init(loader: @escaping (DonationCartOrderParam) -> DonationCartOrderLoader) {
        self.loader = loader
    }
    
    public func load(_ param: DonationCartOrderParam, completion: @escaping (DonationCartOrderResult) -> Void) {
        cancellable = loader(param)
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
