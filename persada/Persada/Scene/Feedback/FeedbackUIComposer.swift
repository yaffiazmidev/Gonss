//
//  FeedbackUIComposer.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

final class FeedbackUIComposer {
    private init() {}
    
    public static func feedbackComposedWith(
        sender: FeedbackSender
    ) -> FeedbackViewController {
        
        let senderService = FeedbackSenderService(sender: MainQueueDispatchDecorator(decoratee: sender))
        
        let controller = FeedbackViewController(delegate: senderService)
        
        senderService.presenter =  FeedBackSenderPresenter(
            successView: WeakRefVirtualProxy(controller),
            loadingView: WeakRefVirtualProxy(controller),
            errorView: WeakRefVirtualProxy(controller))
        
        return controller
    }
}
