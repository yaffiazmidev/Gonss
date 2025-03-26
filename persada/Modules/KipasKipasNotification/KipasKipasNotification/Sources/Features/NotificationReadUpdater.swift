//
//  NotificationReadUpdater.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 26/05/24.
//

import Foundation

public protocol NotificationReadUpdater {
    typealias Result = Swift.Result<NotificationDefaultResponse, Error>
    
    func update(_ request: NotificationReadRequest, completion: @escaping (Result) -> Void)
}
