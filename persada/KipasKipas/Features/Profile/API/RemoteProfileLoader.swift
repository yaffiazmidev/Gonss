//
//  RemoteProfileLoader.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 16/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import Foundation
import KipasKipasNetworking
import FeedCleeps
import KipasKipasShared
import KipasKipasDirectMessage


// MARK: Kalo ada waktu, tolong dirapiin ya
public class RemoteProfileLoader: ProfileLoader {
    private let baseUrl : URL
    private let client: HTTPClient
    
    public init(baseUrl: URL, client: HTTPClient) {
        self.baseUrl = baseUrl
        self.client = client
    }
}

// MARK: - mutual
extension RemoteProfileLoader {
    func mutual(request: ProfileLoaderMutualRequest, completion: @escaping (Swift.Result<RemoteAcountMutualData, Error>) -> Void) {
        let request = DirectMessageEndpoint.allowCall(AllowCallParam(targetAccountId: request.targetAccountId)).url(baseURL: baseUrl)  
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteAcountMutualData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Data
extension RemoteProfileLoader {
    func data(request: ProfileLoaderDataRequest, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void) {
        
        let requestById = HotnewsEndpoint.getProfileById(id: request.userId).url(baseURL: baseUrl)
        let requestByUsername = HotnewsEndpoint.getProfileByUsername(username: request.username).url(baseURL: baseUrl)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request.userId.isEmpty ? requestByUsername : requestById)
                let mapped = try Mapper<Root<RemoteUserProfileData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Post
extension RemoteProfileLoader {
    func post(request: PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<RemoteFeedItemData, Error>) -> Void) {
        let request = HotnewsEndpoint.getFeedVideo(request).url(baseURL: baseUrl)
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteFeedItemData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                if let error = error as? URLError {
                    switch error.code {
                    case .timedOut:
                        completion(.failure(KKNetworkError.responseFailure(
                            KKErrorNetworkResponse(code: "Time Out", message: "Time Out"))))
                    case .cannotFindHost:
                        completion(.failure(KKNetworkError.responseFailure(
                            KKErrorNetworkResponse(code: "Cannot Find Host", message: "Cannot Find Host"))))
                    default:
                        completion(.failure(KKNetworkError.responseFailure(
                            KKErrorNetworkResponse(code: "Unknown Network Error", message: "Unknown Network Error"))))
                    }
                } else {
                    completion(.failure(error))
                }
                
            }
        }
    }
}

// MARK: - Update Picture
extension RemoteProfileLoader {
    func updatePicture(request: ProfileLoaderUpdatePictureRequest, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        let req = ProfileLoaderEndpoint.updatePicture(request: request).url(baseURL: baseUrl)
        
        Task {
            do {
                let (data, response) = try await client.request(from: req)
                let mapped = try Mapper<EmptyData>.map(data, from: response)
                let url = request.pictureUrl.replacingOccurrences(of: "tmp/", with: "")
                completion(.success(url))
            } catch {
                completion(.failure(error))
            }
        }
    }
}



fileprivate enum ProfileLoaderEndpoint {
    case updatePicture(request: ProfileLoaderUpdatePictureRequest)
    
    public func url(baseURL: URL) -> URLRequest {
        switch self {
        case let .updatePicture(request):
            
            var url = baseURL
            url.appendPathComponent("profile")
            url.appendPathComponent(request.userId)
            
            var req = try! URLRequest(url: url, method: .put)
            let jsonData = try! JSONSerialization.data(withJSONObject: ["photo": request.pictureUrl])
            req.httpBody = jsonData
            
            return req
        }
    }
}

extension MainQueueDispatchDecorator: ProfileLoader where T == ProfileLoader {
    func mutual(request: ProfileLoaderMutualRequest, completion: @escaping (Swift.Result<RemoteAcountMutualData, Error>) -> Void){
        decoratee.mutual(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    func data(request: ProfileLoaderDataRequest, completion: @escaping (Swift.Result<FeedCleeps.RemoteUserProfileData, Error>) -> Void) {
        decoratee.data(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    func post(request: FeedCleeps.PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<FeedCleeps.RemoteFeedItemData, Error>) -> Void) {
        decoratee.post(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    func updatePicture(request: ProfileLoaderUpdatePictureRequest, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        decoratee.updatePicture(request: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
