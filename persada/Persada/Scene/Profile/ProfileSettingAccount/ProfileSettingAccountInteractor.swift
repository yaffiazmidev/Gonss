//
//  ProfileSettingAccountInteractor.swift
//  KipasKipas
//
//  Created by Daniel Partogi on 11/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import Foundation

typealias ProfileSettingAccountInteractable = ProfileSettingAccountBusinessLogic & ProfileSettingAccountDataStore

protocol ProfileSettingAccountBusinessLogic {
    
    func doRequest(_ request: ProfileSettingAccountModel.Request)
}

protocol ProfileSettingAccountDataStore {
    var dataSource: ProfileSettingAccountModel.DataSource { get }
}



