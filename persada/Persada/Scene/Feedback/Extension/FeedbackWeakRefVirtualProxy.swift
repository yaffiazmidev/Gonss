//
//  FeedbackWeakRefVirtualProxy.swift
//  KipasKipas
//
//  Created by PT.Koanba on 07/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import KipasKipasShared

// MARK: Update
extension WeakRefVirtualProxy: FeedbackSenderView where T: FeedbackSenderView {
    
    func display(_ viewModel: FeedbackSenderViewModels) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedbackSenderLoadingView where T: FeedbackSenderLoadingView {
    
    func display(_ viewModel: FeedbackSenderLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedbackSenderErrorView where T: FeedbackSenderErrorView {
    
    func display(_ viewModel: FeedbackSenderLoadingErrorViewModel) {
        object?.display(viewModel)
    }
}
