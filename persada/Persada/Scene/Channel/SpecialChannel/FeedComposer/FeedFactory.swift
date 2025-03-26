//
//  FeedControllerFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 10/06/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import FeedCleeps
import UIKit
import KipasKipasNetworking


final class FeedFactory {
    private static var httpClient: HTTPClient = {
        return HTTPClientFactory.makeAuthHTTPClient()
    }()
    
    private static var refreshTokenService: RefreshTokenService = {
        return RefreshTokenService()
    }()
    
    private static var filterCache: FilterDonationTemporaryStore? {
        get { FilterDonationCache().getFilterDonations() }
        set {
            if let value = newValue {
                FilterDonationCache().saveFilterDonations(value: value)
            }
        }
    }
    
    static func createFeedDonationController() -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let baseURL: String = APIConstants.baseURL
        let loader = RemoteFeedDonationModuleLoader(baseURL: baseURL,
                                                    token: token,
                                                    isTokenExpired: AUTH.isTokenExpired(),
                                                    refreshTokenService: refreshTokenService)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token,
                                             isLogin: isLogin,
                                             userID: getIdUser(),
                                             endpoint: APIConstants.baseURL)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: URL(string: baseURL)!,
                                                                 httpClient: httpClient,
                                                                 token: token,
                                                                 refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader,
                                            identifier: .donation,
                                            param: param,
                                            followUnfollowUpdater: followUnfollow)
        presenter.donationCategoryId = filterCache?.categoryId ?? ""
        presenter.filterByProvinceId = filterCache?.provinceId
        presenter.filterByCurrentLocation = (long: filterCache?.longitude, lat: filterCache?.latitude)
        
        let vc = FeedCleepsViewController(
            cleepsCountry: nil,
            mainView: view, feed: [],
            presenter: presenter,
            showBottomCommentSectionView: false,
            isFeed: false,
            isHome: true,
            resetFilterCache: { filterCache = .init() }
        )
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createTrendingController(feed: [Feed] = [], showBottomCommentSectionView: Bool = false, isHome: Bool) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteTrendingCleepsModuleLoader(baseURL: APIConstants.baseURL, token: token, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: httpClient)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .trending, param: param, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, showBottomCommentSectionView: showBottomCommentSectionView, isHome: isHome)
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createHashtagController(hashtag: String, requestedPage: Int, totalPage: Int, feed: [Feed] = [], hasDeleted: Bool = false, displaySingle: Bool = false, type: TiktokType, showBottomCommentSectionView: Bool = false, onClickLike: ((Feed) -> Void)? = nil, onClickComment: ((IndexPath, Int) -> Void)? = nil, isProfile: Bool = false) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteHashtagLoader(hashtag: hashtag, baseURL: APIConstants.baseURL, token: token, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: httpClient)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: type, param: param, requestedPage: requestedPage, totalPage: totalPage, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, hasDeleted: hasDeleted, displaySingle: displaySingle, showBottomCommentSectionView: showBottomCommentSectionView, isFeed: false, isHome: false, isProfile: isProfile)
        vc.router = FeedRouter(controller: vc, onClickLike: onClickLike, onClickComment: onClickComment)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedController(feed: [Feed] = [], hasDeleted: Bool = false, displaySingle: Bool = false, type: TiktokType = .feed, showBottomCommentSectionView: Bool = false, isHome: Bool = false) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFeedModuleLoader(baseURL: APIConstants.baseURL, token: token, httpClient: httpClient, refreshTokenService: refreshTokenService)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: type, param: param,  followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, hasDeleted: hasDeleted, displaySingle: displaySingle, showBottomCommentSectionView: showBottomCommentSectionView, isHome: isHome)
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedChannelContentsController(feed: [Feed] = [], hasDeleted: Bool = false, displaySingle: Bool = false, showBottomCommentSectionView: Bool = false, channelId: String = "") -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFeedChannelContentsLoader(baseURL: APIConstants.baseURL, token: token, channelId: channelId, httpClient: httpClient, refreshTokenService: refreshTokenService)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .channelContents, param: param, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, hasDeleted: hasDeleted, displaySingle: displaySingle, showBottomCommentSectionView: showBottomCommentSectionView, isFeed: false, isHome: false)
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedCleepsController(feed: [Feed] = [], countryCode: CleepsCountry, showBottomCommentSectionView: Bool = false, isHome: Bool = false) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFeedCleepsModuleLoader(cleepsCountry: countryCode, baseURL: APIConstants.baseURL, token: token, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: httpClient)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .cleeps(country: countryCode), param: param, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(cleepsCountry: countryCode, mainView: view, feed: mappedFeed, presenter: presenter, showBottomCommentSectionView: showBottomCommentSectionView, isHome: isHome)
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedProfileController(requestedPage: Int, totalPage: Int, feed: [Feed] = [], userID: String, type: TiktokType, showBottomCommentSectionView: Bool = false, onClickLike: ((Feed) -> Void)? = nil, onClickComment: ((IndexPath, Int) -> Void)? = nil) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteProfileFeedModuleLoader(userID: userID, loggedUserID: getIdUser(), baseURL: APIConstants.baseURL, token: token, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: httpClient)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: type, param: param, requestedPage: requestedPage, totalPage: totalPage, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, showBottomCommentSectionView: showBottomCommentSectionView, enableRefresh: false, isFeed: false, isHome: false)
        vc.router = FeedRouter(controller: vc, onClickLike: onClickLike, onClickComment: onClickComment)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedExploreController(feed: [Feed] = [], hasDeleted: Bool = false, displaySingle: Bool = false, showBottomCommentSectionView: Bool = false, requestedPage: Int,  onClickLike: ((Feed) -> Void)? = nil, onClickComment: ((IndexPath, Int) -> Void)? = nil) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFeedExploreModuleLoader(baseURL: APIConstants.baseURL, token: token, isLogin: isLogin, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: httpClient)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .explore, param: param, requestedPage: requestedPage, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, hasDeleted: hasDeleted, displaySingle: displaySingle, showBottomCommentSectionView: showBottomCommentSectionView, isFeed: false, isHome: false)
        vc.showLiveStreamingList = { showLiveStreamingList?(nil) }
        
        vc.router = FeedRouter(controller: vc, onClickLike: onClickLike, onClickComment: onClickComment)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFeedSearchController(feed: [Feed] = [], hasDeleted: Bool = false, displaySingle: Bool = false, showBottomCommentSectionView: Bool = false, requestedPage: Int, searchText: String,  onClickLike: ((Feed) -> Void)? = nil) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFeedSearchLoader(baseURL: APIConstants.baseURL, token: token, searchText: searchText, httpClient: httpClient, refreshTokenService: refreshTokenService)
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .search, param: param, requestedPage: requestedPage, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, hasDeleted: hasDeleted, displaySingle: displaySingle, showBottomCommentSectionView: showBottomCommentSectionView, isFeed: false, isHome: false)
        vc.router = FeedRouter(controller: vc, onClickLike: onClickLike)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    static func createFollowingCleepsController(feed: [Feed] = [], showBottomCommentSectionView: Bool = false, isHome: Bool = false) -> FeedCleepsViewController {
        let view = FeedCleepsView()
        let token = getToken() ?? ""
        let isLogin = getToken() != nil ? true : false
        let loader = RemoteFollowingCleepsModuleLoader(baseURL: APIConstants.baseURL, token: token, isTokenExpired: AUTH.isTokenExpired(), refreshTokenService: refreshTokenService, httpClient: HTTPClientFactory.makeHTTPClient())
        let filteredLoader = FeedLoaderFilteredByBlockedUserDecorator(blockedUserStore: KeychainBlockedUserStore(), loader: loader)
        let param = FeedCleepsPresenterParam(token: token, isLogin: isLogin, userID: getIdUser(), endpoint: APIConstants.baseURL)
        let url = URL(string: APIConstants.baseURL)!
        let suggestion = HardcodeRemoteFollowingSuggestionLoader(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let followUnfollow = HardcodeRemoteFollowUnfollowUpdater(url: url, httpClient: httpClient, token: token, refreshTokenService: refreshTokenService)
        let presenter = FeedCleepsPresenter(loader: filteredLoader, identifier: .following, param: param, followingSuggestionLoader: suggestion, followUnfollowUpdater: followUnfollow)
        let mappedFeed = feed.map {
            FeedItemMapper.map(feed: $0)
        }
        let vc = FeedCleepsViewController(mainView: view, feed: mappedFeed, presenter: presenter, showBottomCommentSectionView: showBottomCommentSectionView, isFeed: false, isHome: isHome)
        vc.router = FeedRouter(controller: vc)
        setLastOpenedFeedCleepsView(presenter.identifier)
        return vc
    }
    
    private static func setLastOpenedFeedCleepsView(_ type: TiktokType){
        UserDefaults.standard.set(type.rawValue, forKey: "lastOpenedFeedCleepsView")
    }
}
