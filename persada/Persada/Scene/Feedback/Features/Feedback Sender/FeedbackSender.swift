//
//  FeedbackSender.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol FeedbackSender {
    typealias Result = Swift.Result<FeedbackSenderItem, Error>
    
    func send(request: FeedbackSenderRequest, completion: @escaping (Result) -> Void)
}
