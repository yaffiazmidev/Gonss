//
//  FeedbackSenderViewProtocols.swift
//  KipasKipas
//
//  Created by PT.Koanba on 06/12/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol FeedbackSenderView {
    func display(_ viewModel: FeedbackSenderViewModels)
}

protocol FeedbackSenderLoadingView {
    func display(_ viewModel: FeedbackSenderLoadingViewModel)
}

protocol FeedbackSenderErrorView {
    func display(_ viewModel: FeedbackSenderLoadingErrorViewModel)
}
