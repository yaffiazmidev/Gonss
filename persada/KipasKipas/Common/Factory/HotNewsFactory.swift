//
//  HotNewsFactory.swift
//  KipasKipas
//
//  Created by DENAZMI on 10/11/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import FeedCleeps
import KipasKipasNetworking
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI
import KipasKipasShared
import KipasKipasStory
import KipasKipasStoryiOS
import Combine

class RemoteHotnewsLoader: HotnewsLoader {
    
    private let baseURL: URL
    private let client: HTTPClient
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    func getUserProfile(byId profileId: String, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void) {
        let request = HotnewsEndpoint.getProfileById(id: profileId).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteUserProfileData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getUserProfile(byUsername username: String, completion: @escaping (Swift.Result<RemoteUserProfileData, Error>) -> Void) {
        let request = HotnewsEndpoint.getProfileByUsername(username: username).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteUserProfileData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func followUser(byId userId: String, completion: @escaping (Error?) -> Void) {
        let request = HotnewsEndpoint.followUser(id: userId).url(baseURL: baseURL)
        
        Task {
            do {
                try await client.request(from: request)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func likePost(byId id: String, isLiking: Bool, completion: @escaping (Error?) -> Void) {
        let request = HotnewsEndpoint.likeFeed(id: id, isLiking: isLiking).url(baseURL: baseURL)
        Task {
            do {
                try await client.request(from: request)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func getFeedVideo(with request: PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<RemoteFeedItemData, Error>) -> Void) {
      
        Task {
            let request = HotnewsEndpoint.getFeedVideo(request).url(baseURL: baseURL)
            
            do {
                let (data, response) = try await fetchWithRetry(from: request, retries: 5, delay: 2)
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
    
    enum NetworkError: Error {
        case invalidResponse
        case retryLimitReached
    }

    private func fetchWithRetry(from request: URLRequest, retries: Int, delay: TimeInterval) async throws -> (Data, HTTPURLResponse) {
        var currentAttempt = 0
        var lastError: Error?
        
        while currentAttempt < retries {
            do {
                return try await client.request(from: request)
            } catch {
                lastError = error
                currentAttempt += 1
                if currentAttempt < retries {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.retryLimitReached
    }
    
    func seenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void) {
        let request = HotnewsEndpoint.seenPost(id: id).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<SeenResponse>.map(data, from: response)
                completion(.success(mapped))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func guestSeenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void) {
        let request = HotnewsEndpoint.guestSeenPost(id: id).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<SeenResponse>.map(data, from: response)
                completion(.success(mapped))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getFeed(byId id: String,isLogin:Bool, completion: @escaping (Swift.Result<RemoteFeedItemContent, Error>) -> Void) {
        let request = HotnewsEndpoint.getFeed(id: id,isLogin:isLogin ).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteFeedItemContent>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func getFollowingSuggest(page: Int, size: Int, completion: @escaping (Swift.Result<RemoteFollowingSuggestData, Error>) -> Void) {
        let request = HotnewsEndpoint.getSuggestFollowing(page: page, size: size).url(baseURL: baseURL)
        
        Task {
            do {
                let (data, response) = try await client.request(from: request)
                let mapped = try Mapper<Root<RemoteFollowingSuggestData>>.map(data, from: response)
                completion(.success(mapped.data))
            } catch {
                completion(.failure(error))
            }
        }
    }
}

class HotNewsFactory {
    private static let  baseURL = URL(string: APIConstants.baseURL)!
    private static let client: HTTPClient = HTTPClientFactory.makeAuthHTTPClient(timeoutInterval: 10.0)
    
    private static var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
        label: "com.koanba.kipaskipas.KKDonationRankMicroApps.queue",
        qos: .userInitiated,
        attributes: .concurrent
    ).eraseToAnyScheduler()
    
    private static func makeListStoryLoader(_ request: StoryListRequest) -> StoryListLoader {
        let request = StoryEndpoint.list(request: request).url(baseURL: baseURL)

        return client
            .getPublisher(request: request)
            .tryMap(Mapper<StoryListResponse>.map)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    static func create(by feedType: FeedType, profileId: String, page: Int = 0, selectedFeedId: String = "", alreadyLoadFeeds: [FeedItem] = [], mediaType: FeedMediaType? = nil, channelId: String = "", searchKeyword: String = "") -> IHotNewsViewController {
        let token = getToken() ?? ""
        let url = AUTH.isLogin() ? baseURL : baseURL.appendingPathComponent("public")
        let loader = RemoteHotnewsLoader(baseURL: url, client: client)
        
        let controller = HotNewsRouter.create(
            loader: MainQueueDispatchDecorator(decoratee: loader), 
            storyListLoader: StoryListInteractorAdapter(loader: makeListStoryLoader),
            baseUrl: APIConstants.baseURL,
            authToken: token,
            feedType: feedType,
            isLogin: AUTH.isLogin(),
            page: page,
            profileId: profileId,
            selectedFeedId: selectedFeedId,
            alreadyLoadFeeds: alreadyLoadFeeds,
            mediaType: mediaType,
            channelId: channelId,
            searchKeyword: searchKeyword, 
            totalFollowing: getFollowing()
        )
        controller.setRouter(router: HotNewsFactoryRouter(controller: controller, feedType: feedType))
        return controller
    }
    
    static func createHotRoom(by feedType: FeedType, profileId: String, page: Int = 0, selectedFeedId: String = "", alreadyLoadFeeds: [FeedItem] = [], mediaType: FeedMediaType? = nil, channelId: String = "", searchKeyword: String = "") -> IHotNewsViewController {
        let token = getToken() ?? ""
        
        let client = HTTPClientFactory.makeAuthHTTPClient(timeoutInterval: 10.0)
//        let baseURL = URL(string: APIConstants.baseURL)!
        let url = AUTH.isLogin() ? baseURL : baseURL.appendingPathComponent("public")
        let loader = RemoteHotnewsLoader(baseURL: url, client: client)
        let controller = HotNewsRouter.createHotRoom(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            baseUrl: APIConstants.baseURL,
            authToken: token,
            feedType: feedType,
            isLogin: AUTH.isLogin(),
            page: page,
            profileId: profileId,
            selectedFeedId: selectedFeedId,
            alreadyLoadFeeds: alreadyLoadFeeds,
            mediaType: mediaType,
            channelId: channelId,
            searchKeyword: searchKeyword,
            totalFollowing: getFollowing()
        )
        controller.setRouter(router: HotNewsFactoryRouter(controller: controller, feedType: feedType))
        return controller
    }
    
    static func createHotRoomSingFeed(selectedFeedId: String,isFromPushFeed:Bool) -> IHotNewsViewController {
        let token = getToken() ?? ""
        
        let client = HTTPClientFactory.makeAuthHTTPClient(timeoutInterval: 10.0)
        let url = AUTH.isLogin() ? baseURL : baseURL.appendingPathComponent("public")
        let loader = RemoteHotnewsLoader(baseURL: url, client: client)
        let controller = HotNewsRouter.createHotRoom(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            baseUrl: APIConstants.baseURL,
            authToken: token,
            feedType: .profile,
            isLogin: AUTH.isLogin(),
            page: 0,
            profileId: "",
            selectedFeedId: selectedFeedId,
            alreadyLoadFeeds: [],
            mediaType: nil,
            channelId: "",
            searchKeyword: "",
            totalFollowing: getFollowing(),
            isForSingleFeed:true,
            isFromPushFeed:isFromPushFeed 
        )
    controller.setRouter(router: HotNewsFactoryRouter(controller: controller, feedType: .profile))
        return controller
    }
    
    
    static func createSingleFeed(selectedFeedId: String) -> IHotNewsViewController {
        let token = getToken() ?? ""
        
        let client = HTTPClientFactory.makeAuthHTTPClient(timeoutInterval: 5.0)
        let url = AUTH.isLogin() ? baseURL : baseURL.appendingPathComponent("public")
        let loader = RemoteHotnewsLoader(baseURL: url, client: client)
        let controller = HotNewsRouter.create(
            loader: MainQueueDispatchDecorator(decoratee: loader),
            baseUrl: APIConstants.baseURL,
            authToken: token,
            feedType: .profile,
            isLogin: AUTH.isLogin(),
            page: 0,
            profileId: "",
            selectedFeedId: selectedFeedId,
            alreadyLoadFeeds: [],
            mediaType: nil,
            channelId: "",
            searchKeyword: "", 
            totalFollowing: getFollowing(),
            isForSingleFeed: true
        )
        controller.setRouter(router: HotNewsFactoryRouter(controller: controller, feedType: .profile))
        return controller
    }
}

extension MainQueueDispatchDecorator: HotnewsLoader where T == HotnewsLoader {
    
    public func getUserProfile(byId profileId: String, completion: @escaping (Swift.Result<FeedCleeps.RemoteUserProfileData, Error>) -> Void) {
        decoratee.getUserProfile(byId: profileId) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func getUserProfile(byUsername username: String, completion: @escaping (Swift.Result<FeedCleeps.RemoteUserProfileData, Error>) -> Void) {
        decoratee.getUserProfile(byUsername: username) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func followUser(byId userId: String, completion: @escaping (Error?) -> Void) {
        decoratee.followUser(byId: userId) { [weak self] error in
            self?.dispatch { completion(error) }
        }
    }
    
    public func likePost(byId id: String, isLiking: Bool, completion: @escaping (Error?) -> Void) {
        decoratee.likePost(byId: id, isLiking: isLiking) { [weak self] error in
            self?.dispatch { completion(error) }
        }
    }
    
    public func getFeedVideo(with request: PagedFeedVideoLoaderRequest, completion: @escaping (Swift.Result<RemoteFeedItemData, Error>) -> Void) {
        decoratee.getFeedVideo(with: request) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func seenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void) {
        decoratee.seenPost(byId: id) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func guestSeenPost(byId id: String, completion: @escaping (Swift.Result<SeenResponse, Error>) -> Void) {
        decoratee.guestSeenPost(byId: id) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func getFeed(byId id: String,isLogin:Bool, completion: @escaping (Swift.Result<FeedCleeps.RemoteFeedItemContent, Error>) -> Void) {
        decoratee.getFeed(byId: id, isLogin: isLogin) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
    
    public func getFollowingSuggest(page: Int, size: Int, completion: @escaping (Swift.Result<RemoteFollowingSuggestData, Error>) -> Void) {
        decoratee.getFollowingSuggest(page: page, size: size) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

struct HotNewsFeedExploreParam {
    let id: String
    let currentPage: Int
    let totalPage: Int
    let contents: [FeedItem]
}
