//
//  MyStoreSettingInteractor.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 18/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation

typealias MyStoreSettingInteractable = MyStoreSettingBusinessLogic & MyStoreSettingDataStore

protocol MyStoreSettingBusinessLogic {

}

protocol MyStoreSettingDataStore {
    var dataSource: MyStoreSettingModel.DataSource { get }
}

final class MyStoreSettingInteractor: Interactable, MyStoreSettingDataStore {

    var dataSource: MyStoreSettingModel.DataSource
    var authNetworkModel: AuthNetworkModel
    var presenter: MyStoreSettingPresentationLogic

    init(viewController: MyStoreSettingDisplayLogic?, dataSource: MyStoreSettingModel.DataSource) {
        self.dataSource = dataSource
        self.authNetworkModel = AuthNetworkModel()
        self.presenter = MyStoreSettingPresenter(viewController)
    }
}

// MARK: - MyStoreSettingBusinessLogic
extension MyStoreSettingInteractor: MyStoreSettingBusinessLogic {

}


