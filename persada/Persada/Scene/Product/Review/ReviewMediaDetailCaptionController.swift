//
//  ReviewMediaDetailCaptionController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 02/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared

class ReviewMediaDetailCaptionController: CustomHalfViewController{
    private let mainView: ReviewMediaDetailCaptionView
    private let data: ReviewItem
    
    required init(data: ReviewItem, view: ReviewMediaDetailCaptionView){
        self.mainView = view
        self.data = data
        super.init(nibName: nil, bundle: nil)
        viewHeight = 650
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.reviewCell.setupView(data, showMedia: false)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        containerView.setCornerRadius = 0
        containerView.addSubview(mainView.pillView)
        containerView.addSubview(mainView.reviewView)
        
        mainView.pillView.anchor(top: containerView.topAnchor, paddingTop: 10, width: 100, height: 4)
        mainView.pillView.centerXTo(containerView.centerXAnchor)
        mainView.reviewView.anchor(top: mainView.pillView.bottomAnchor, left: containerView.leftAnchor, right: containerView.rightAnchor, paddingTop: 10)
    }
}
