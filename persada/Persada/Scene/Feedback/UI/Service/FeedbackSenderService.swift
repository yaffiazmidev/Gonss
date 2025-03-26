//
//  FeedbackSenderService.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

class FeedbackSenderService: FeedbackViewDelegate {
    
    private let sender: FeedbackSender
    var presenter: FeedBackSenderPresenter?
    
    init(
        sender: FeedbackSender
    ) {
        self.sender = sender
    }
    
    func didSendFeedback(request: FeedbackSenderRequest) {
        presenter?.didStartLoadingSendFeedback()
        sender.send(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                self.presenter?.didFinishLoadingSendFeedback(with: item)
            case let .failure(error):
                self.presenter?.didFinishLoadingSendFeedback(with: error)
            }
        }
    }
}
