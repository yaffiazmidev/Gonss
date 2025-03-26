//
//  NetworkModel.swift
//  Persada
//
//  Created by Muhammad Noor on 05/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import Foundation
import Combine
import Alamofire

extension HTTPURLResponse {
    var hasSuccessStatusCode: Bool {
        return 200...203 ~= statusCode
    }
    
}

struct ErrorMessage: Decodable, Error {
    let statusCode: Int?
    let statusData: String?
    let statusMessage: String?
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status"
        case statusMessage = "message"
        case statusData = "data"
        case code = "code"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            self.statusData = try container.decode(String.self, forKey: .statusData)
        } catch  {
            do {
                let value = try container.decode(Array<String>.self, forKey: .statusData)
                self.statusData = value.first
            } catch {
                self.statusData = "Nothing"
            }
        }
        
        do {
            self.statusCode = try container.decode(Int.self, forKey: .statusCode)
        } catch  {
            self.statusCode = 400
        }
        
        do {
            self.code = try container.decode(String.self, forKey: .code)
        } catch  {
            self.code = "401"
        }
        
        do {
            self.statusMessage = try container.decode(String.self, forKey: .statusMessage)
        } catch  {
            self.statusMessage = ""
        }
    }
    
    init(statusCode: Int, statusMessage: String, statusData: String, code: String = "") {
        self.statusCode = statusCode
        self.statusData = statusData
        self.statusMessage = statusMessage
        self.code = code
    }
    
}


enum ResultData<T> {
    case success(T)
    case failure(ErrorMessage?)
}

class NetworkModel {
    
    func requestData<T: Decodable>(_ url: URLRequest, _ completion: @escaping (ResultData<T>) -> Void) {
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let validData = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(nil))
                return
            }
            
            let success = httpResponse.statusCode >= 200 && httpResponse.statusCode < 203
            
            if success, let decodeData = try? JSONDecoder().decode(T.self, from: validData) {
                completion(.success(decodeData))
            } else if !success, let decodeError = try? JSONDecoder().decode(ErrorMessage.self, from: validData) {
                
                let errorWithProperStatusCode = ErrorMessage(
                    statusCode: httpResponse.statusCode,
                    statusMessage: decodeError.statusMessage ?? "",
                    statusData: decodeError.statusData ?? "",
                    code: decodeError.code ?? "")
                
                completion(.failure(errorWithProperStatusCode))
            }
        }.resume()
    }
    
    func fetchURL<T: Codable>(_ url: URLRequest) -> AnyPublisher<T, Error> {
        AF.request(url).publishData().tryMap{ result in
                guard let data = result.data else {
                    let apiError = ErrorMessage(statusCode: 404, statusMessage: "Data not found", statusData: "")
                    throw apiError
                }
                
                let decoder = JSONDecoder()
                
                switch result.response?.statusCode ?? 404 {
                case 200...299:
                    do {
                        let result = try decoder.decode(T.self, from: data)
                        return result
                    } catch let error {
                        let apiError = ErrorMessage(statusCode: result.response?.statusCode ?? 404, statusMessage: error.localizedDescription, statusData: "")
                        throw apiError
                    }
                default:
                    let apiError = ErrorMessage(statusCode: result.response?.statusCode ?? 404, statusMessage: "Unknow error", statusData: "")
                    throw apiError
                }
            }.eraseToAnyPublisher()
    }
    
    func fetchImage(_ url: URLRequest) -> AnyPublisher<Data, Error> {
        
        AF.request(url)
            .publishData()
            .tryMap{ result in
                let decoder = JSONDecoder()
                guard let urlResponse = result.response,
                            (200...203).contains(urlResponse.statusCode) else {
                    let apiError = try decoder.decode(ErrorMessage.self, from: result.data ?? Data())
                    throw apiError
                }
                
                return result.data ?? Data() }
            .eraseToAnyPublisher()
    }

}
