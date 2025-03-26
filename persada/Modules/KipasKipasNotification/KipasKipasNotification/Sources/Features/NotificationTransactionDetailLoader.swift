//
//  NotificationTransactionDetailLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 10/05/24.
//

import Foundation

public protocol NotificationTransactionDetailLoader {
    typealias ResultTransaction = Swift.Result<NotificationTransactionDetailItem ,Error>
    
    func load(request: NotificationTransactionDetailRequest, completion: @escaping (ResultTransaction) -> Void)
}
