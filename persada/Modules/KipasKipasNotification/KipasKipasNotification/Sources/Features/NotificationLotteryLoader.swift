//
//  NotificationLotteryLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 25/07/24.
//

import Foundation

public protocol NotificationLotteryLoader {
    typealias Result = Swift.Result<NotificationLotteryItem, Error>
    
    func load(request: NotificationLotteryRequest, completion: @escaping (Result) -> Void )
}
