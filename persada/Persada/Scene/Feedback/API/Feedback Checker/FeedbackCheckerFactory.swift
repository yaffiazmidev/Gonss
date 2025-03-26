//
//  FeedbackCheckerFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 08/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class FeedbackCheckerFactory {
    
    static func create() -> FeedbackChecker {
        let baseURL = URL(string: APIConstants.baseURL)!
        let checker = RemoteFeedbackChecker(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())
        return MainQueueDispatchDecorator(decoratee: checker)
    }
}
