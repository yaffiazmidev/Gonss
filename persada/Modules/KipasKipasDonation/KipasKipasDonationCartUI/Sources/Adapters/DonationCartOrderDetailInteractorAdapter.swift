//
//  DonationCartOrderDetailInteractorAdapter.swift
//  KipasKipasDonationCart
//
//  Created by Rahmat Trinanda Pramudya Amar on 29/02/24.
//

import Foundation
import Combine

public final class DonationCartOrderDetailInteractorAdapter {
    
    public typealias DonationCartOrderDetailResult = Swift.Result<DonationCartOrderDetail, Error>
    
    private var cancellable: AnyCancellable?
    
    private let loader: (String) -> DonationCartOrderDetailLoader
    
    public init(loader: @escaping (String) -> DonationCartOrderDetailLoader) {
        self.loader = loader
    }
    
    public func load(by id: String, completion: @escaping (DonationCartOrderDetailResult) -> Void) {
        cancellable = loader(id)
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
