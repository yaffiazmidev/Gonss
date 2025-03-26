//
//  UnivLinkManager.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 25/03/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum DeeplinkPage {
    case donation(id: String)
    case feed(feed: Feed)
    case registerVerification(code: String, token: String)
    case resetPasswordVerification(code: String, token: String)
}

protocol UniversalLinkDelegate: AnyObject {
    func navigate(to page: DeeplinkPage)
}

class UniversalLinkManager {
    
    private weak var delegate: UniversalLinkDelegate?

    private let network: FeedNetworkModel = FeedNetworkModel()
    private var headerSubscriptions = [AnyCancellable]()
    
    init(delegate: UniversalLinkDelegate) {
        self.delegate = delegate
    }
    
    func handleNavigationUniversalLink(object: NSUserActivity) -> Bool {
        // Get URL components from the incoming user activity.
        guard object.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = object.webpageURL,
              let components = URLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
            return false
        }
        
        if components.path.contains("feed") {
            let feedId = incomingURL.lastPathComponent
            getFeedById(id: feedId) { [weak self] feeds in
                self?.delegate?.navigate(to: .feed(feed: feeds))
            }
            return true
        }
        
        if components.path.contains("donation") {
            let campaignId = incomingURL.lastPathComponent
            delegate?.navigate(to: .donation(id: campaignId))
            return true
        }
        
        if incomingURL[hasFirstPath: "verification"] {
            if let code = incomingURL[query: "code"],
               let token = incomingURL[query: "token"] {
                delegate?.navigate(to: .registerVerification(code: code, token: token))
            }
        }
        
        if incomingURL[hasFirstPath: "forgot-password"] {
            if let code = incomingURL[query: "code"],
               let token = incomingURL[query: "token"] {
                delegate?.navigate(to: .resetPasswordVerification(code: code, token: token))
            }
        }
        
        let queries = components.queryItems ?? []
        
        if queries.contains(where: { ($0.name == "status_code" && ($0.value == "200"))}) {
            NotificationCenter.default.post(name: .updateDonationCampaign, object: nil)
        }
        
        // Check for specific URL components that you need.
        let result = KKQRHelper.parseUrl(incomingURL.absoluteString)
        switch result {
        case let .success(item):
            NotificationCenter.default.post(name: .qrNotificationKey, object: nil, userInfo: ["QRItem" : item])
            return true
            
        case .failure:
            return false
        }
    }
    
    private func getFeedById(id: String, onSuccess: @escaping (Feed) -> ()) {
        let isLogin = getToken() != nil ? true : false
        if isLogin {
            requestFeedById(.postDetail(id: id), onSuccess)
        } else {
            requestFeedById(.postDetailPublic(id: id), onSuccess)
        }
       
    }
    
    private func requestFeedById(_ request: FeedEndpoint,_ onSuccess: @escaping (Feed) -> ()) {
        network.PostDetail(request).sink(receiveCompletion: { [weak self] (completion) in
            guard self != nil else { return }
            switch completion {
            case .failure(let error):
                print(error.localizedDescription)
            case .finished: break
            }
        }) { [weak self] (model: PostDetailResult) in
            guard self != nil else { return }
            if let feed = model.data {
                onSuccess(feed)
            }
        }.store(in: &headerSubscriptions)
    }
}

extension URL {
    subscript (query name: String) -> String? {
        guard let components = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false
        ) else { return nil }
        
        let filtered = components.queryItems?.first(where: { $0.name == name })
        return filtered?.value
    }
    
    subscript (hasFirstPath path: String) -> Bool {
        guard let components = URLComponents(
            url: self,
            resolvingAgainstBaseURL: false
        ) else { return false }
        
        let paths = components.path.split(separator: "/")
        
        guard let firstPath = paths.first.map(String.init) else {
            return false
        }
        
        let comparison = firstPath.compare(
            path,
            options: .caseInsensitive
        )
        
        return comparison == .orderedSame
    }
}

