//
//  ProductRouter.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ProductRouting {
	
	func routeTo(_ route: ProductModel.Route)
}

final class ProductRouter: Routeable {
	
	private weak var viewController: UIViewController?
	
	init(_ viewController: UIViewController?) {
		self.viewController = viewController
	}
    
    func toArchive(){
        let myArchiveProduct = ProductArchiveController(mainView: ProductArchiveView(), dataSource: ProductArchiveModel.DataSource())
        viewController?.navigationController?.pushViewController(myArchiveProduct, animated: true)
    }
}


// MARK: - ProductRouting
extension ProductRouter: ProductRouting {
	
	func routeTo(_ route: ProductModel.Route) {
		DispatchQueue.main.async {
			switch route {

				case .selectedComment(let id, let dataStore):
					self.showComment(id: id, dataStore: dataStore)
				case .showProfile(let id, let type):
					self.showProfile(id: id, type: type)
				case .report(let id, let accountId, let imageUrl):
					self.report(id: id, accountId: accountId, imageUrl: imageUrl)
				case .dismissProduct:
					self.dismiss()
				case .seeProduct(let shop):
					self.seeProduct(shop)
				case .visitStore:
					self.visitStore()
				case .addProduct:
					self.addProduct()
				case .addAdress:
					self.navigateToAddAddress()
                case .showQR:
                    self.showQRCode()
			}
		}
	}
}


// MARK: - Private Zone
private extension ProductRouter {
	
	func showProfile(id: String, type: String) {
		let controller =  AnotherUserProfileViewController(mainView: AnotherUserProfileView(), dataSource: NewUserProfileModel.DataSource())
		controller.setProfile(id: id, type: type)
		controller.bindNavigationBar("", true)
        
        viewController?.navigationController?.push(controller)
	}

	func showComment(id: String, dataStore: CommentHeaderCellViewModel) {

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
		viewController?.navigationController?.popViewController(animated: false)
	}
	
	func visitStore() {
		let chooseProduct = ChooseProductController(viewModel: ChooseProductViewModel(playersService: ProductNetworkModel()))
		
		viewController?.present(chooseProduct, animated: false, completion: nil)
	}
	
	func seeProduct(_ shop: Product) {
		let detailController = ProductDetailFactory.createProductDetailController(dataSource: shop)
		
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
		let addAddressController = EditAddressController(mainAddView: AddAddressView(), address: nil, type: .add, isSeller: .seller)

		viewController?.navigationController?.pushViewController(addAddressController, animated: false)
	}
    
    func showQRCode(){
        let readerCodeController = KKQRCameraViewController()
        readerCodeController.handleWhenExtracted = { item in
            switch item.type {
            case .shop:
                let detailProductController = ProductDetailFactory.createProductDetailController(dataSource: Product())
                detailProductController.idProduct = item.id
                detailProductController.isUnivLink = true
                self.viewController?.navigationController?.pushViewController(detailProductController, animated: true)
                readerCodeController.dismiss(animated: false, completion: nil)
            case .donation:
                let vc = DonationDetailViewController(donationId: item.id, feedId: "")
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
                readerCodeController.dismiss(animated: false, completion: nil)
            }
        }
        viewController?.present(readerCodeController, animated: true, completion: nil)
    }
    
}
