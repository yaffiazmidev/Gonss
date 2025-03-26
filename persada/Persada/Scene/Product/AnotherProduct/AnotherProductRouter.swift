//
//  AnotherProductRouter.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/06/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

protocol AnotherProductRouting {
	
	func routeTo(_ route: AnotherProductModel.Route)
}

final class AnotherProductRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
}


// MARK: - AnotherProductRouting
extension AnotherProductRouter: AnotherProductRouting {
	
	func routeTo(_ route: AnotherProductModel.Route) {
		DispatchQueue.main.async {
			switch route {
			
			case .selectedComment(let id, let dataStore):
				self.showComment(id: id, dataStore: dataStore)
			case .showProfile(let id, let type):
				self.showProfile(id: id, type: type)
			case .report(let id, let accountId, let imageUrl):
				self.report(id: id, accountId: accountId, imageUrl: imageUrl)
            case .dismiss:
				self.dismiss()
            case .seeProduct(let shop, let account):
                self.seeProduct(shop, account)
			case .addAdress:
				self.navigateToAddAddress()
			}
		}
	}
}


// MARK: - Private Zone
private extension AnotherProductRouter {
	
	func showProfile(id: String, type: String) {
        let controller = ProfileRouter.create(userId: id)
        controller.bindNavigationBar("", icon: "ic_chevron_left_outline_black", customSize: .init(width: 20, height: 14), contentHorizontalAlignment: .fill, contentVerticalAlignment: .fill)
        controller.hidesBottomBarWhenPushed = true
		let navigate = UINavigationController(rootViewController: controller)
		navigate.modalPresentationStyle = .fullScreen
		
		viewController?.present(navigate, animated: true, completion: nil)
	}

	func showComment(id: String, dataStore: CommentHeaderCellViewModel) {

		var dataSource = CommentModel.DataSource()
		dataSource.id = id
		dataSource.postId = id
        
        let comment = CommentDataSource(id: id)
        let controller = CommentViewController(commentDataSource: comment)
        controller.bindNavigationBar(.get(.commenter), true)
        controller.hidesBottomBarWhenPushed = true

		viewController?.navigationController?.pushViewController(controller, animated: false)
	}
	
	func report(id: String, accountId: String, imageUrl: String) {

		var dataSource = ProductModel.DataSource()
		dataSource.paramReport = (id: id, accountId: accountId, imageUrl: imageUrl)
		let commentController = ReportFeedController(viewModel: ReportFeedViewModel(id: id, imageUrl: imageUrl, accountId: accountId, networkModel: ReportNetworkModel()))

		viewController?.navigationController?.pushViewController(commentController, animated: false)
	}
	
	func dismiss() {
        viewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        viewController?.navigationController?.popViewController(animated: true)
	}
	
	func seeProduct(_ shop: Product, _ account: Profile?) {
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: shop, account: account)
		
		detailController.hidesBottomBarWhenPushed = true
		viewController?.navigationController?.pushViewController(detailController, animated: false)
	}

	func addProduct() {
		let controller = PostController(mainView: PostView(isCreateFeed: false), dataSource: PostModel.DataSource(typePost: "product"))
		controller.bindNavigationBar("", false)
		
		let navigate = UINavigationController(rootViewController: controller)
		navigate.modalPresentationStyle = .fullScreen
		
		viewController?.present(navigate, animated: false, completion: nil)
	}

	func navigateToAddAddress(){
        let addAddressController = EditAddressController(mainAddView: AddAddressView(), address: nil, type: .add, isSeller: .buyer)

		viewController?.navigationController?.pushViewController(addAddressController, animated: false)
	}

}
