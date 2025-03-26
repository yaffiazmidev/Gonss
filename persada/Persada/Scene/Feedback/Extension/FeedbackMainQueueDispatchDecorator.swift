//
//  FeedbackMainQueueDispatchDecorator.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

extension MainQueueDispatchDecorator: FeedbackSender where T == FeedbackSender {
    
    func send(request: FeedbackSenderRequest, completion: @escaping (FeedbackSender.Result) -> Void) {
        decoratee.send(request: request)  { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}


extension MainQueueDispatchDecorator: FeedbackChecker where T == FeedbackChecker {
    
    func check(completion: @escaping (FeedbackChecker.Result) -> Void) {
        decoratee.check { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
