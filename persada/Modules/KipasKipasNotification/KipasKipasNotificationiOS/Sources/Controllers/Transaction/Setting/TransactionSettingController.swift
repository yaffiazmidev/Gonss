//
//  TransactionSettingController.swift
//  KipasKipasNotificationiOS
//
//  Created by Rahmat Trinanda Pramudya Amar on 27/03/24.
//

import UIKit
import KipasKipasShared

class TransactionSettingController: CustomHalfViewController {
    let mainView: TransactionSettingView
    
    required init() {
        mainView = TransactionSettingView()
        super.init(nibName: nil, bundle: nil)
        mainView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        canSlideUp = false
        viewHeight = 300
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

// MARK: - Helper
private extension TransactionSettingController {}

extension TransactionSettingController: TransactionSettingViewDelegate {
    func didTapClose() {
        animateDismissView()
    }
    
    func didSwitch(for item: TransactionViewSwitch, isOn: Bool) {
        switch item {
        case .activity:
            break
        case .review:
            break
        case .promotion:
            break
        }
    }
}
