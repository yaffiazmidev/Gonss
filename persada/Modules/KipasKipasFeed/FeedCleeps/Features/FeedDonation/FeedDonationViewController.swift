//
//  FeedDonationViewController.swift
//  KipasKipasFeed
//
//  Created by DENAZMI on 11/10/23.
//

import UIKit

protocol IFeedDonationViewController: AnyObject {
	// do someting...
}

class FeedDonationViewController: UIViewController {
	var interactor: IFeedDonationInteractor!
	var router: IFeedDonationRouter!

	override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

extension FeedDonationViewController: IFeedDonationViewController {
	// do someting...
}
