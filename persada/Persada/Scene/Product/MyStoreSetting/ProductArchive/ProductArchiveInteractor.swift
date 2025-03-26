//
//  ProductArchiveInteractor.swift
//  KipasKipas
//
//  Created by Ibrohim Dasuqi on 02/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

typealias ProductArchiveInteractable = ProductArchiveDataStore

//protocol ArchiveProductBusinessLogic {
//    func doRequest()
//    func setCourier()
//}

protocol ProductArchiveDataStore {
    var dataSource: ProductArchiveModel.DataSource { get set }
}

final class ProductArchiveInteractor: Interactable, ProductArchiveDataStore {

    var dataSource: ProductArchiveModel.DataSource
    var presenter: ProductArchivePresentationLogic

    init(viewController: ProductArchiveDisplayLogic?, dataSource: ProductArchiveModel.DataSource) {
        self.dataSource = dataSource
        self.presenter = ProductArchivePresenter(viewController)
    }
}

// MARK: - ArchiveProductBusinessLogic
//extension ArchiveProductInteractor: ArchiveProductBusinessLogic {
//    func doRequest() {
//        _loadingState.accept(true)
//    }
//
//    func setCourier() {
//
//    }
//}
