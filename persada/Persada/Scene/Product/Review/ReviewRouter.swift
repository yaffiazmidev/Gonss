//
//  ReviewRouter.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 17/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import ContextMenu

protocol ReviewRouting {
    func dismiss()
    func allMedia(_ id: String, loader: ReviewMediaPagedLoader)
    func detailMedia(_ items: [ReviewMedia], itemAt: Int, loader: ReviewMediaPagedLoader?, request: ReviewPagedRequest?, onMediasUpdated: (([ReviewMedia], ReviewPagedRequest, Bool) -> Void)?)
}

final class ReviewRouter: ReviewRouting{
    let controller: UIViewController!
    
    required init(controller: UIViewController!) {
        self.controller = controller
    }
    
    func dismiss() {
        controller.navigationController?.popViewController(animated: true)
    }
    
    func allMedia(_ id: String, loader: ReviewMediaPagedLoader) {
        let vc = ReviewMediaViewController(idProduct: id, loader: loader)
        let router = ReviewRouter(controller: vc)
        vc.router = router
        controller.navigationController?.pushViewController(vc, animated: true)
    }
    
    func detailMedia(_ items: [ReviewMedia], itemAt: Int, loader: ReviewMediaPagedLoader? = nil, request: ReviewPagedRequest? = nil, onMediasUpdated: (([ReviewMedia], ReviewPagedRequest, Bool) -> Void)? = nil) {
        let vc = ReviewMediaDetailViewController(medias: items, itemAt: itemAt)
        let router = ReviewRouter(controller: vc)
        vc.router = router
        vc.loader = loader
        vc.request = request
        vc.onMediasUpdated = onMediasUpdated
        controller.navigationController?.pushViewController(vc, animated: true)
    }
}
