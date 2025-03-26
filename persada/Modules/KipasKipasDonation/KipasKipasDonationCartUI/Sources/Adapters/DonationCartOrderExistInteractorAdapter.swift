//
//  DonationCartOrderExistInteractorAdapter.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 28/02/24.
//

import Foundation
import Combine

final public class DonationCartOrderExistInteractorAdapter {
    
    public typealias DonationCartOrderExistResult = Swift.Result<DonationCartOrderExist, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: () -> DonationCartOrderExistLoader
    
    public init(loader: @escaping () -> DonationCartOrderExistLoader) {
        self.loader = loader
    }
    
    public func load(completion: @escaping (DonationCartOrderExistResult) -> Void) {
        cancellable = loader()
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
