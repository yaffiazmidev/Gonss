//
//  NotificationSystemMuteController.swift
//  KipasKipasNotificationiOS
//
//  Created by DENAZMI on 26/04/24.
//

import UIKit
import KipasKipasShared

class NotificationSystemMuteController: CustomHalfViewController {

    let mainView: NotificationSystemMuteView
    
    init() {
        mainView = NotificationSystemMuteView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        canSlideUp = false
        viewHeight = 170
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.addSubview(mainView)
        mainView.anchors.leading.equal(containerView.anchors.leading)
        mainView.anchors.trailing.equal(containerView.anchors.trailing)
        mainView.anchors.top.equal(containerView.anchors.top)
        mainView.anchors.bottom.equal(containerView.safeAreaLayoutGuide.anchors.bottom)
    }
}
