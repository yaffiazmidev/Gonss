//
//  FeedbackViewDelegate.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol FeedbackViewDelegate {
    func didSendFeedback(request: FeedbackSenderRequest)
}
