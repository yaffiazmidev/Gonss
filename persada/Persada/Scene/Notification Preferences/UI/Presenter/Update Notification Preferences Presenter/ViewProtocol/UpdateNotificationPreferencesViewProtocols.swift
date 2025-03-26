//
//  UpdateNotificationPreferencesViewProtocols.swift
//  KipasKipas
//
//  Created by PT.Koanba on 15/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation

protocol UpdateNotificationPreferencesView {
    func display(_ viewModel: UpdateNotificationPreferencesViewModel)
}

protocol UpdateNotificationPreferencesLoadingView {
    func display(_ viewModel: UpdateNotificationPreferencesLoadingViewModel)
}

protocol UpdateNotificationPreferencesErrorView {
    func display(_ viewModel: UpdateNotificationPreferencesLoadingErrorViewModel)
}
