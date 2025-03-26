//
//  RxNetwork.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 18/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import RxCocoa

// TODO: update whatever u need, it's basic \(@_@)/

final class Network<T: Decodable> {

    private let endPoint: String
    private let scheduler: ConcurrentDispatchQueueScheduler
    
    public init() {
        self.endPoint = APIConstants.baseURL
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
    }
    
    func getItems(_ path: String) -> Observable<[T]> {
        let absolutePath = "\(endPoint)\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ data -> [T] in
                return try JSONDecoder().decode([T].self, from: data)
            })
    }
    
    func getItems(_ path: String) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .debug()
            .observeOn(scheduler)
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func getItems(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        print("---DEBUG: \(absolutePath) : \(parameters)")
        let startTime = CFAbsoluteTimeGetCurrent()
        
        return Observable<T>.create { observer in
            if let url = URL(string: absolutePath) {
                var urlRequest = URLRequest(url: url)
                urlRequest.allHTTPHeaderFields = parameters as? [String: String]
                urlRequest.httpMethod = "GET"
                urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let encoderURLRequest = urlRequest.encode(with: parameters)
                AF.request(encoderURLRequest)
                    .validate()
                    .responseDecodable(of: T.self) { response in
                        guard let data = response.data else {return}
                        switch response.result {
                        case .success(let value):
                            let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
                            print("----DEBUG: \(absolutePath) : \(parameters), in: \(timeElapsed) s")
                            observer.onNext(value)
                            observer.onCompleted()
                        case .failure(let err):
                            observer.onError(err)
                        }
                    }
            }
            return Disposables.create()
        }
    }
    
    func getItemsWithURLParam(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        let converted = parameters.compactMapValues { $0 as? String }
        return Observable<T>.create { observer in
            var url = URLComponents(string: absolutePath)!
            url.queryItems = self.queryItems(dictionary: converted)
            var urlRequest = URLRequest(url: url.url!)
            urlRequest.httpMethod = "GET"
            urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoderURLRequest = urlRequest.encode(with: parameters)
            
            AF.request(encoderURLRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    guard let data = response.data else {return}
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func queryItems(dictionary: [String:String]) -> [URLQueryItem] {
        return dictionary.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
    }
    
    func getItem(_ path: String, parameters: Parameters?, headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        print("---:DEBUG \(absolutePath)\n---\(parameters ?? [:])")
        return RxAlamofire
            .data(.get, URL(string: absolutePath)!, parameters: parameters, headers: HTTPHeaders(headers))
            .debug()
            .observeOn(scheduler)
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func getItemBalence(_ path: String, parameters: Parameters?, headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        let converted = parameters?.compactMapValues { $0 as? String }
        return Observable<T>.create { observer in
            var url = URLComponents(string: absolutePath)!
            url.queryItems = self.queryItems(dictionary: converted ?? [:])
            var urlRequest = URLRequest(url: url.url!)
            urlRequest.httpMethod = HTTPMethod.get.rawValue
            urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoderURLRequest = urlRequest.encode(with: parameters)
            debugPrint("---:DEBUG \(url.url!)")
            AF.request(encoderURLRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func postItem(_ path: String, parameters: [String: Any], headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        return RxAlamofire
            .request(.post, URL(string: absolutePath)!, parameters: parameters, headers: HTTPHeaders(headers))
            .debug()
            .observeOn(scheduler)
            .data()
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func updateItem(_ path: String, parameters: [String: Any], headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)/"
        return RxAlamofire
            .request(.patch, URL(string: absolutePath)!, parameters: parameters, headers: HTTPHeaders(headers))
            .debug()
            .observeOn(scheduler)
            .data()
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func updateItemWithURLParam(_ path: String, parameters: [String: Any], headers: [String: String], method : HTTPMethod = .patch) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        let converted = parameters.compactMapValues { $0 as? String }
        return Observable<T>.create { observer in
            var url = URLComponents(string: absolutePath)!
            url.queryItems = self.queryItems(dictionary: converted)
            var urlRequest = URLRequest(url: url.url!)
            urlRequest.httpMethod = method.rawValue
            urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoderURLRequest = urlRequest.encode(with: parameters)
            debugPrint("---:DEBUG \(url.url!)")
            AF.request(encoderURLRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    guard let data = response.data else {return}
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func updateItemPut(_ path: String, parameters: [String: Any], headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)/"
        return RxAlamofire
            .request(.put, URL(string: absolutePath)!, parameters: parameters, headers: HTTPHeaders(headers))
            .debug()
            .observeOn(scheduler)
            .data()
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func putItem(_ path: String, parameters: [String: Any]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        return Observable<T>.create { observer in
            let url = URL(string: absolutePath)!
            var urlRequest = URLRequest(url: url)
            var jsonData = Data()
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch {
                print(error.localizedDescription)
            }
            
            urlRequest.httpMethod = "PUT"
            urlRequest.addValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = jsonData
            
//            let encoderURLRequest = urlRequest.encode(with: parameters)
            
            AF.request(urlRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    guard let data = response.data else {return}
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func putItem(_ request: EndpointType) -> Observable<T> {
        
        return Observable<T>.create { observer in
            
            let dataBody = try! JSONSerialization.data(withJSONObject: request.body)
            let convertString = String(data: dataBody, encoding: .utf8) ?? ""
            
            var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
            urlRequest.httpBody = convertString.data(using: .utf16)
            
            urlRequest.httpMethod = request.method.rawValue
            urlRequest.allHTTPHeaderFields = request.header as? [String: String]
            
            let encodeURLRequest = urlRequest.encode(with: request.parameter)
            
            AF.request(encodeURLRequest)
                .validate()
                .responseDecodable(of: T.self) { response in
                    guard let data = response.data else {return}
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(let err):
                        observer.onError(err)
                    }
                }
            
            return Disposables.create()
        }
    }
    
    func deleteItem(_ path: String, parameters: [String: Any], headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)/"
        return RxAlamofire
            .request(.delete, absolutePath, parameters: parameters, headers: HTTPHeaders(headers))
            .debug()
            .observeOn(scheduler)
            .data()
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }
    
    func postItemNew(_ path: String, parameters: [String: Any], headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        var request = URLRequest(url: URL(string: absolutePath)!)
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        
        return RxAlamofire.request(request as URLRequestConvertible).debug().observeOn(scheduler).data().map({ data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        })
        
        
    }
    
    func postItemNew(_ request: EndpointType, body: Data) -> Observable<T> {
        
        var urlRequest = URLRequest(url: request.baseUrl.appendingPathComponent(request.path))
        urlRequest.httpBody = body
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.header as? [String: String]
        
        let encodeURLRequest = urlRequest.encode(with: request.parameter)
        
        return RxAlamofire.request(encodeURLRequest as URLRequestConvertible).debug().observeOn(scheduler).data().map({ data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        })
    }
    
    func postItemObject(_ path: String, parameters: CheckoutOrderRequest, headers: [String: String]) -> Observable<T> {
        let absolutePath = "\(endPoint)\(path)"
        var request = URLRequest(url: URL(string: absolutePath)!)
        
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(parameters)
//        let json = String(data: jsonData, encoding: String.Encoding.utf16)
        
        request.httpBody = jsonData
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getToken() ?? "")", forHTTPHeaderField: "Authorization")
        
        
        return RxAlamofire.request(request as URLRequestConvertible).debug().observeOn(scheduler).data().map({ data -> T in
            return try JSONDecoder().decode(T.self, from: data)
        })
        
        
    }
}

