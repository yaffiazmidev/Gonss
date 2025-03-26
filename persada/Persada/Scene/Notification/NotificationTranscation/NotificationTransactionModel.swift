//
//  NotificationTransactionModel.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum NotificationTransactionModel {
	
	enum Request {
		case fetchNotificationTransaction
	}
	
	enum Response {
		case notificationTransaction(result: NotificationTransactionResult)
	}
	
	enum ViewModel {
		case transaction(viewModel: [NotificationTransaction])
	}
	
	enum Route {
		case detailTransaction(id: String)
		case detailDonation(id: String)
		case statusTransaction
		case dismiss
	}
	
	struct DataSource: DataSourceable {
		var data: [NotificationTransaction]?
	}

}
