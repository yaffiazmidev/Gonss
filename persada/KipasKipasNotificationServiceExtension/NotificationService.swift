//
//  NotificationService.swift
//  KipasKipasNotificationServiceExtension
//
//  Created by movan on 02/12/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UserNotifications
import OneSignal

class NotificationService: UNNotificationServiceExtension {
	
	var contentHandler: ((UNNotificationContent) -> Void)?
	var bestAttemptContent: UNMutableNotificationContent?
	var receivedRequest: UNNotificationRequest!
	
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.receivedRequest = request;
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let userInfo = request.content.userInfo
        let custom = userInfo["custom"]
        print("**** Running NotificationServiceExtension: userInfo = \(userInfo.description)")
        print("**** Running NotificationServiceExtension: custom = \(custom.debugDescription)")
        
        if let bestAttemptContent = bestAttemptContent {
          //OneSignal.Debug.setLogLevel()
          //OneSignal.Debug.setAlertLevel(.LL_NONE)
          //bestAttemptContent.body = "[Modified] " + bestAttemptContent.body
          
            OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent)
            
          //OneSignal.didReceiveNotificationExtensionRequest(self.receivedRequest, with: self.bestAttemptContent, withContentHandler: self.contentHandler)
            
            contentHandler(bestAttemptContent)
        }
    }

    
//	func didReceive_(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//		self.contentHandler = contentHandler
//		self.receivedRequest = request
//		bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//		
//        print("****** notif 4")
//        
//		if let bestAttemptContent = bestAttemptContent {
//			// Modify the notification content here...
//			bestAttemptContent.title = "\(bestAttemptContent.title)"
//			
//			let payload = request.content.userInfo
//			
//			let customObject = payload["custom"] as? [String: AnyObject]
//
//			if let urlPath = customObject?["a"]?["photo"] as? String,
//				 let imageURL = URL(string: urlPath) {
//
//				let destination = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(imageURL.lastPathComponent)
//
//				do {
//					let data = try Data(contentsOf: imageURL)
//					try data.write(to: destination)
//					let attachment = try UNNotificationAttachment(identifier: "", url: destination)
//					bestAttemptContent.attachments = [attachment]
//				} catch { }
//			}
//			
//			contentHandler(bestAttemptContent)
//		}
//	}
	
	override func serviceExtensionTimeWillExpire() {
		// Called just before the extension will be terminated by the system.
		// Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
		if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
			contentHandler(bestAttemptContent)
		}
	}
	
}
