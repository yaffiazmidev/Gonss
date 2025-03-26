//
//  NotificationUnreadLoader.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 22/05/24.
//

import Foundation

public protocol NotificationUnreadLoader {
    typealias Result = Swift.Result<NotificationUnreadItem, Error>
    func load(completion: @escaping (Result) -> Void)
}
