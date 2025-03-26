//
//  NotificationSocialModel.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import Foundation

enum NotificationSocialModel {
	
	enum Request {
		case fetchNotificationSocial
	}
	
	enum Response {
		case notificationSocial(result: NotificationSocialResult)
	}
	
	enum ViewModel {
		case social(viewModel: [NotificationSocial])
	}
	
	enum Route {
		case showComment(id: String)
		case showSubcomment(id: String)
		case showPostLike(id: String)
		case showCommentLike(id: String)
		case showSubcommentLike(id: String)
		case showFollow(id: String)
		case dismiss
	}
	
	struct DataSource: DataSourceable {
		var data: [NotificationSocial]?
	}
}
