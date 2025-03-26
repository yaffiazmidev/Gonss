//
//  NotificationSystemIsReadCheck.swift
//  KipasKipasNotification
//
//  Created by DENAZMI on 17/05/24.
//

import Foundation

public protocol NotificationSystemIsReadCheck {
    typealias ResultSystemIsRead = Swift.Result<NotificationDefaultResponse, Error>
    
    func check(request: NotificationSystemIsReadRequest, completion: @escaping (ResultSystemIsRead) -> Void )
}
