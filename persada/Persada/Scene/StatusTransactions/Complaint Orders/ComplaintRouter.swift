//
//  ComplaintRouter.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol ComplaintRouting {
	
	func routeTo(_ route: ComplaintModel.Route)
}

final class ComplaintRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - ComplaintRouting
extension ComplaintRouter: ComplaintRouting {
	
	func routeTo(_ route: ComplaintModel.Route) {
		DispatchQueue.main.async {
			switch route {
			
			case .dismissComplaintScene:
				self.dismissComplaintScene()
			case let .preview(images, media):
				self.preview(images, media)
			case .confirmComplaint:
				self.confirmComplaint()
			}
		}
	}
}


// MARK: - Private Zone
private extension ComplaintRouter {
	
	func dismissComplaintScene() {
		viewController?.dismiss(animated: true)
	}
	
	func preview(_ image: UIImage, _ media: ResponseMedia) {
		
	}
	
	func confirmComplaint() {
		let controller = ComplaintConfirmController()
		
		viewController?.navigationController?.pushViewController(controller, animated: true)
	}
}
