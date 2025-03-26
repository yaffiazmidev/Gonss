//
//  UploadProgressViewFactory.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 18/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import Foundation
import KipasKipasShared
import UIKit
import KipasKipasNetworkingUtils

class UploadProgressViewFactory {
    static func create() -> UploadProgressView {
        let view = UploadProgressView(frame: CGRect(x: 0, y: 0, width: 56, height: 56))
        view.translatesAutoresizingMaskIntoConstraints = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 14
        view.isHidden = true
        view.uploader = MainQueueDispatchDecorator(decoratee: MediaUploadManager())
        return view
    }
}
