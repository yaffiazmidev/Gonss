//
//  FeedDonationInteractor.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 11/10/23.
//

import UIKit

protocol IFeedDonationInteractor: AnyObject {
    // do someting...
}

class FeedDonationInteractor: IFeedDonationInteractor {
    
    private let presenter: IFeedDonationPresenter
    
    init(presenter: IFeedDonationPresenter) {
        self.presenter = presenter
    }
}
