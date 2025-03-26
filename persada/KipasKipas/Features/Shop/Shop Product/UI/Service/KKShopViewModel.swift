//
//  KKShopViewModel.swift
//  KipasKipas
//
//  Created by DENAZMI on 05/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation

protocol IKKShopViewModel {
    func requestProductSpecialDiscount()
    func requestSelectedStore()
}

class KKShopViewModel: IKKShopViewModel {
    
    var delegate: ShopViewControllerDelegate?
    private let network: DataTransferService
    
    init(network: DataTransferService) {
        self.network = network
    }
    
    func requestProductSpecialDiscount() {
//        let endpoint: Endpoint<RemoteProductEtalase> = Endpoint(
//            path: "product",
//            method: .get,
//            queryParameters: ["etalase": 1]
//        )
//        
//        network.request(with: endpoint) { [weak self] result in
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let response):
//                self.delegate?.displayProductSpecialDiscount(with: response.data ?? [])
//            case .failure(let error):
//                self.delegate?.displayErrorGetProductSpecialDiscount(with: error.message)
//            }
//        }
        
        
        var request = URLRequest(url: URL(string: "https://tools.kipaskipas.com/api/v1/product?etalase=1")!, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        DefaultURLSessionService.shared.get(request: request) { (result: Swift.Result<RemoteProductEtalase?, Error>) in
            switch result {
            case .success(let response):
                self.delegate?.displayProductSpecialDiscount(with: response?.data ?? [])
            case .failure(let error):
                self.delegate?.displayErrorGetProductSpecialDiscount(with: error.localizedDescription)
            }
        }
    }
    
    func requestSelectedStore() {
        var request = URLRequest(url: URL(string: "https://tools.kipaskipas.com/api/v1/store")!, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        DefaultURLSessionService.shared.get(request: request) { (result: Swift.Result<RemoteStoreItem?, Error>) in
            switch result {
            case .success(let response):
                self.delegate?.displayStores(with: response?.data ?? [])
            case .failure(let error):
                self.delegate?.displayErrorGetStores(with: error.localizedDescription)
            }
        }
    }
}

class DefaultURLSessionService {
    static let shared = DefaultURLSessionService()
    
    func get<T: Decodable>(request: URLRequest, completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
//        DispatchQueue.global(qos: .background).async {
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "Data not found..", code: 404)
                    completion(.failure(error))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    let error = NSError(domain: String(data: data, encoding: .utf8) ?? "", code: 404)
                    completion(.failure(error))
                    return
                }
                
                guard response.statusCode == 200 else {
                    let error = NSError(domain: String(data: data, encoding: .utf8) ?? "", code: response.statusCode)
                    completion(.failure(error))
                    return
                }
                
                self.decode(data: data, completion: completion)
            }
            
            task.resume()
//        }
    }
    
    private func decode<T: Decodable>(data: Data, completion: @escaping ((Swift.Result<T, Error>) -> Void)) {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(T.self, from: data)
            completion(.success(result))
        } catch {
            let error = NSError(domain: String(data: data, encoding: .utf8) ?? "", code: 404)
            completion(.failure(error))
        }
    }
}
