//
//  FeedbackUIFactory.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

final class FeedbackUIFactory {
    
    static func create(onSubmitSuccess: @escaping () -> Void) -> FeedbackViewController {
        let baseURL = URL(string: APIConstants.baseURL)!
        let sender = RemoteFeedbackSender(url: baseURL, client: HTTPClientFactory.makeAuthHTTPClient())

        let controller = FeedbackUIComposer.feedbackComposedWith(sender: sender)
        controller.onSubmitSuccess = onSubmitSuccess
        return controller
    }
}
