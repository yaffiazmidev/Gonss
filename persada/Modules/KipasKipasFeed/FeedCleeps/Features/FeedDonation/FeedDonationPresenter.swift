//
//  FeedDonationPresenter.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 11/10/23.
//

import UIKit

protocol IFeedDonationPresenter {
	// do someting...
}

class FeedDonationPresenter: IFeedDonationPresenter {
	weak var controller: IFeedDonationViewController?
	
	init(controller: IFeedDonationViewController) {
		self.controller = controller
	}
}
