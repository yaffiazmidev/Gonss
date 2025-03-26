//
//  RxNotificationNetworkModel.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 03/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import RxSwift

public final class RxNotificationNetworkModel {
    private let network: Network<NotificationSocialResult>
    private let networkTransaction: Network<NotificationTransactionResult>
    private let networkTransactionDetail: Network<TransactionProductResult>
    private let networkDefault: Network<DefaultResponse>
    
    init(network: Network<NotificationSocialResult>, networkTransaction: Network<NotificationTransactionResult>, networkTransactionDetail: Network<TransactionProductResult>, networkDefault: Network<DefaultResponse>) {
        self.network = network
        self.networkTransaction = networkTransaction
        self.networkTransactionDetail = networkTransactionDetail
        self.networkDefault = networkDefault
    }
    
    func fetchNotificationSocial(page: Int, size: Int) -> Observable<NotificationSocialResult> {
        let requestEndpoint = NotificationEndpoint.social(page: page, size: size)
        return network.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
    }
    
    func fetchNotificationTransaction(page: Int, size: Int) -> Observable<NotificationTransactionResult> {
        let requestEndpoint = NotificationEndpoint.transaction(page: page, size: size)
        return networkTransaction.getItemsWithURLParam(requestEndpoint.path, parameters: requestEndpoint.parameter)
    }
    
    func detailNotificationTransaction(id: String) -> Observable<TransactionProductResult> {
        let requestEndpoint = NotificationEndpoint.detailTransaction(id: id)
        return networkTransactionDetail.getItem(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: requestEndpoint.header as! [String: String])
    }
    
    func isReadNotification(type: String, id: String) -> Observable<DefaultResponse> {
        let requestEndpoint = NotificationEndpoint.isReadNotification(type: type, id: id)
        return networkDefault.updateItem(requestEndpoint.path, parameters: requestEndpoint.parameter, headers: requestEndpoint.header as! [String: String])
    }
    
}
