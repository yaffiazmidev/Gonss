//
//  ProductActionSheet.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 28/06/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

@objc protocol ProductActionSheetDelegate {
    func activeSuccess()
    func activeError(errorMsg: String)
    func archiveSuccess()
    func archiveError(errorMsg: String)
    func deleteSuccess(_ index: Int)
    func deleteError(errorMsg: String)
    @objc optional func resellerUpdated()
}

class ProductActionSheet : NSObject {
    
    private var delegate : ProductActionSheetDelegate?
    private var viewModel : ViewModelProductActionSheet?
    
    private var rightOptions: [String: ((UIAlertAction) -> Void)] = [
        .get(.sharedPost): {_ in},
        .get(.sharedAnotherMedia): {_ in},
        //        .get(.sendToDM): {_ in},
        .get(.archiveProduct): {_ in},
        .get(.activeProduct): {_ in},
        .get(.editProduct): {_ in},
        .get(.deleteProduct): {_ in},
        .get(.setProductReseller): {_ in},
        .get(.addResellerProduct): {_ in},
        .get(.stopBecomeReseller): {_ in},
    ]
    
    private weak var controller : UIViewController?
    private var product : ProductItem?
    private var indexProduct: Int = 0
    private var fromDetail: Bool = false
    private var isVerified: Bool = false
    var isArchive: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(controller: UIViewController, delegate: ProductActionSheetDelegate, fromDetail: Bool = false, isVerified: Bool = false, isArchive: Bool = false) {
        self.init()
        self.controller = controller
        self.viewModel = ViewModelProductActionSheet()
        self.delegate = delegate
        self.fromDetail = fromDetail
        self.isVerified = isVerified
        self.isArchive = isArchive
        handleRightOption()
    }
    
    func showSheet(_ product: ProductItem, index: Int = 0){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let isUser = product.accountId.isItUser()
        let isOriginalUser = product.originalAccountId?.isItUser() ?? false || product.type == .original
        let status = ProductStatusActivePage(rawValue: (product.generalStatus))
        self.product = product
        self.indexProduct = index
        handleRightOption()
        if isUser {
            if status == .inactive {
                actionSheet.addAction(addActionSheetMenu(title: .get(.activeProduct)))
                actionSheet.addAction(addActionSheetMenu(title: .get(.editProduct)))
                actionSheet.addAction(UIAlertAction(title: .get(.deleteProduct), style: .destructive, handler: self.rightOptions[.get(.deleteProduct)]))
            }else if status == .active {
                actionSheet.addAction(addActionSheetMenu(title: .get(.sharedPost)))
                //                actionSheet.addAction(addActionSheetMenu(title: .get(.sendToDM)))
                actionSheet.addAction(addActionSheetMenu(title: .get(.sharedAnotherMedia)))
                if isOriginalUser {
                    actionSheet.addAction(addActionSheetMenu(title: .get(.archiveProduct)))
                    actionSheet.addAction(addActionSheetMenu(title: (product.isResellerAllowed ? "Edit" : "Atur") + .get(.setProductReseller), handlerName: .get(.setProductReseller)))
                    actionSheet.addAction(addActionSheetMenu(title: .get(.editProduct)))
                } else {
                    if fromDetail && product.isResellerAllowed {
                        if product.isAlreadyReseller {
                            actionSheet.addAction(addActionSheetMenu(title: .get(.stopBecomeReseller)))
                        } else {
                            actionSheet.addAction(addActionSheetMenu(title: .get(.addResellerProduct)))
                        }
                    }
                }
            }
        } else {
            if fromDetail && product.isAlreadyReseller || !fromDetail {
                actionSheet.addAction(addActionSheetMenu(title: .get(.sharedPost)))
                //                actionSheet.addAction(addActionSheetMenu(title: .get(.sendToDM)))
            }
            actionSheet.addAction(addActionSheetMenu(title: .get(.sharedAnotherMedia)))
            if product.type == .reseller {
                if fromDetail {
                    if product.isAlreadyReseller {
                        actionSheet.addAction(addActionSheetMenu(title: .get(.stopBecomeReseller)))
                    } else {
                        actionSheet.addAction(addActionSheetMenu(title: .get(.addResellerProduct)))
                    }
                } else {
                    actionSheet.addAction(addActionSheetMenu(title: .get(.stopBecomeReseller)))
                }
            }
            
        }
        
        actionSheet.addAction(UIAlertAction(title: .get(.cancel), style: .destructive, handler:{ (UIAlertAction)in
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        actionSheet.overrideUserInterfaceStyle = .light
        
        controller?.present(actionSheet, animated: true, completion: {
            actionSheet.view.superview?.subviews.first?.isUserInteractionEnabled = true
            actionSheet.view.superview?.subviews.first?.onTap(action: {
                actionSheet.dismiss(animated: true)
            })
        })
    }
    
    func addActionSheetMenu(title : String, handlerName: String? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default, handler: self.rightOptions[handlerName ?? title])
    }
    
    
    func handleRightOption(){
        rightOptions = [
            .get(.sharedPost): {_ in
                self.shareAsPost()
            },
            .get(.sharedAnotherMedia): {_ in
                self.shareToAnotherMedia()
            },
//            .get(.sendToDM): {_ in
//                self.sendToDm()
//            },
            .get(.archiveProduct): {_ in
                self.archiveProduct()
            },
            .get(.activeProduct): {_ in
                self.activeProduct()
            },
            .get(.editProduct): {_ in
                self.editProduct()
            },
            .get(.deleteProduct): {_ in
                self.deleteProduct()
            },
            .get(.setProductReseller): {_ in
                self.setProductReseller()
            },
            .get(.addResellerProduct): {_ in
                self.addResellerProduct()
            },
            .get(.stopBecomeReseller): {_ in
                self.stopBecomeReseller()
            }
        ]
    }
    
    
    func saveQR() {
        let icon = UIImage(named: .get(.AppIcon))
        let qr = KKQRHelper.generate(KKQRItem(type: .shop, id: product?.id ?? ""), withIcon: icon)!
        
        UserDefaults.standard.set(true, forKey: KKQRHelper.userDefaultKey)
        UIImageWriteToSavedPhotosAlbum(qr, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let alert = UIAlertController(title: .get(.failed), message: error.localizedDescription, preferredStyle: .alert)
            alert.overrideUserInterfaceStyle = .light
            alert.addAction(UIAlertAction(title: .get(.ok), style: .default))
            controller?.present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: .get(.success), message: .get(.qrsavesuccess), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: .get(.ok), style: .default))
            alert.overrideUserInterfaceStyle = .light
            controller?.present(alert, animated: true)
        }
    }
    
    // share image
    func shareQR() {
        let icon = UIImage(named: .get(.AppIcon))
        let qr = KKQRHelper.generate(KKQRItem(type: .shop, id: product?.id ?? ""), withIcon: icon)!
        
        // set up activity view controller
        let imageToShare = [qr]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = controller?.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        //        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        
        // present the view controller
        controller?.present(activityViewController, animated: true, completion: nil)
    }
    
    private let vw_upload : UploadingStoryView = {
        let v = UploadingStoryView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        v.translatesAutoresizingMaskIntoConstraints = true
        return v
    }()
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    func shareAsPost(){
        let dataSource = PostModel.DataSource()
        let vc = PostController(mainView: PostView(isCreateFeed: true), dataSource: dataSource)
        guard let prod = product?.toProduct() else { fatalError("Product cannot be empty")}
        if let id = prod.id {
            self.productYouHaveSeen(with: id)
        }
        vc.shareAsProductHandler(product: prod)
        vc.onPostClickCallback = { param in
            self.vw_upload.uploadPost(param: param) {
                guard let view = self.controller?.view else { fatalError("No Parent View")}
                DispatchQueue.main.async {
                    self.hud.show(in: view)
                }
            }
        }
        vw_upload.actionFinishUpload = {
            DispatchQueue.main.async {
                self.hud.dismiss()
            }
            self.showDialog(title: .get(.uploadSuccessfull), desc: .get(.uploadPostProductSucessfullMessage))
        }
        vc.hidesBottomBarWhenPushed = true
        vc.isShareProductAsPost = true
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func shareAsStory(){
        //Open camera & upload to story
//        let vc = VCCamera()
//        vc.actionUploadSuccess = { product, image, data in
//            self.showDialog(title: .get(.uploadSuccessfull), desc: .get(.uploadSucessfullMessage))
//        }
//        vc.product = product?.toProduct()
//
//        controller?.present(vc, animated: true, completion: nil)
    }
    
    func shareToAnotherMedia(){
        if let name = product?.name, let productID = product?.id , let url = product?.medias?.first?.thumbnail?.large, let accountId = product?.accountId {
            self.productYouHaveSeen(with: productID)
            let text =  "Beli produk \(name) - Klik link berikut untuk membuka tautan: \(APIConstants.webURL)/shop/\(productID)"
            
            let item = CustomShareItem(id: productID, message: text, type: .shop, assetUrl: url, accountId: accountId, name: name, price: product?.price)
            let vc = KKShareController(mainView: KKShareView(), item: item)
            controller?.present(vc, animated: true, completion: nil)
        }
    }
    
    func archiveProduct(){
        if let id = product?.id {
            viewModel?.archiveProduct(productID: id, archive: false) {
                self.delegate?.archiveSuccess()
            } onArchiveError: { (error) in
                self.delegate?.archiveError(errorMsg: error)
            }
        }
    }
    
    func editProduct(){
        let vc = EditProductController(mainView: EditProductView(), dataSource: product?.toProduct())
        vc.indexProduct = self.indexProduct
        vc.isArchive = isArchive
        controller?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setProductReseller(){
        guard isVerified else {
            let validatorController = ResellerValidatorVerifiedController()
            controller?.present(validatorController, animated: true)
            return
        }
        
        if let product = self.product {
            let vc = ResellerSetProductFactory.createController(product)
            vc.onSuccess = self.delegate?.resellerUpdated
            controller?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func deleteProduct(){
        if let id = product?.id {
            self.showDialogDelete(productID: id)
        }
    }
    
    func activeProduct(){
        if let id = product?.id {
            viewModel?.archiveProduct(productID: id, archive: true) {
                Toast.share.show(message: .get(.productActiveDesc)) { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.activeSuccess()
                }
            } onArchiveError: { (error) in
                self.delegate?.activeError(errorMsg: error)
            }
        }
    }
    
    func showDialogDelete(productID : String){
        let alert = UIAlertController(title: .get(.menghapusProduk), message: .get(.menghapusProduKDescription), preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        
        alert.addAction(UIAlertAction(title: .get(.batalkan), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: .get(.hapusProduk), style: .destructive, handler: { action in
            if let id = self.product?.id {
                self.viewModel?.deleteProduct(productID: id) {
                    self.delegate?.deleteSuccess(self.indexProduct)
                } onDeleteError: { (error) in
                    self.delegate?.deleteError(errorMsg: error)
                }
                
            }
        }))
        controller?.present(alert, animated: true, completion: nil)
    }
    
    func showDialog(title: String, desc: String){
        let alert = UIAlertController(title: title, message: desc, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .light
        
        alert.addAction(UIAlertAction(title: .get(.ok), style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        controller?.present(alert, animated: true, completion: nil)
    }
    
    func sendToDm() {
        //TODO : Send to DM
    }
    
    func addResellerProduct() {
        //TODO : addResellerProduct
    }
    
    func stopBecomeReseller() {
        //TODO : stopBecomeReseller
        guard let validProduct = product else {
            return
        }
        
        let stopBecomeResellerController = StopBecomeResellerUIFactory.create(params: RemoveResellerParams(id: validProduct.id)) { [weak self] in
            guard let self = self else { return }
            
            self.delegate?.resellerUpdated?()
        }
        
        controller?.present(stopBecomeResellerController, animated: false)
    }
    
    func productYouHaveSeen(with id: String) {
        guard AUTH.isLogin() else { return }
        
        let service = DIContainer.shared.apiDataTransferService
        
        let endpoint = Endpoint<DefaultResponse>(
            path: "products/\(id)/seen",
            method: .put,
            headerParamaters: ["Authorization" : "Bearer \(getToken() ?? "")", "Content-Type":"application/json"],
            queryParameters: ["type" : "SHARE"] )
        
        service.request(with: endpoint) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case let .failure(error):
                print("PE-9838 sukses", error.message)
            case let .success(response):
                guard let message = response.message else { return }
                print("PE-9838 sukses", message)
            }
        }
    }
}
