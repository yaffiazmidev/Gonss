//
//  ProductDetailController.swift
//  Persada
//
//  Created by movan on 22/07/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVKit
import AVFoundation
import KipasKipasDirectMessage
import KipasKipasDirectMessageUI

class ProductDetailController : UIViewController, UIGestureRecognizerDelegate {
	private let mainView: ProductDetailView
	private let emptyView = ProductDetailNotAvailableView()
	private var router: ProductDetailRouter!
	var presenter : ProductDetailPresenter!
    private let reviewLoader: ReviewPagedLoader!
    private let reviewMediaLoader: ReviewMediaPagedLoader!
	private var disposeBag = DisposeBag()

    private var product: Product?
	var deleteCallback : () -> () = {}
    var handleRefreshList: (() -> Void)? = ({})
    let popup = AuthPopUpViewController(mainView: AuthPopUpView())
	
	var isPresent = false
    var isFromEdit = false
    var isUnivLink = false
	var idProduct = ""
	var isFromFeed = false
	var isPreview = false
    var isArchive = false {
        didSet {
            productActionSheet.isArchive = isArchive
        }
    }
    var account: Profile?
    
    var reviewMedias: [ReviewMedia]?
    var timestampStorage: TimestampStorage = TimestampStorage()
	
	fileprivate lazy var productActionSheet : ProductActionSheet = {
        let sheet = ProductActionSheet(controller: self, delegate: self, fromDetail: true, isVerified: self.presenter.profileRelay.value?.isVerified ?? false, isArchive: isArchive)
		return sheet
	}()
    
    private lazy var channelSearchUseCase: GroupChannelSearchUseCase = {
        let useCase = GroupChannelSearchUseCase()
        return useCase
    }()
	
    init(mainView: ProductDetailView, dataSource: Product?, isPreview: Bool = false, account: Profile? = nil, reviewLoader: ReviewPagedLoader, reviewMediaLoader: ReviewMediaPagedLoader) {
		self.mainView = mainView
        self.reviewLoader = reviewLoader
        self.reviewMediaLoader = reviewMediaLoader
        
		super.init(nibName: nil, bundle: nil)
		
		idProduct = dataSource?.id ?? ""
        self.product = dataSource
		self.isPreview = isPreview
		router = ProductDetailRouter(self)
		presenter = ProductDetailPresenter(router: router, product: dataSource)
        self.account = account
	
	}
    
    func navigateToMediaDetail(index: Int, isPlayVideo: Bool = false) {
        let vc = MediaDetailViewController(medias: product?.medias ?? presenter.product.medias ?? [],
                                           selectedMediaIndex: index, isPlayVideo: isPlayVideo)
        vc.bindNavigationBar()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        if let _ = product {
            self.refreshView()
            presenter.getDetailProduct(idProduct, {
                self.updateUsername()
            })
        } else {
            presenter.getDetailProduct(idProduct, {
                self.refreshView()
            })
        }
        
        
        mainView.imageSlider.rx.setDelegate(self).disposed(by: disposeBag)
        
        presenter.imagesRelay.asObservable().bind(to: mainView.imageSlider.rx.items(cellIdentifier: String.get(.cellID), cellType: ImageCell.self)) {
            index, data, cell in
            
            cell.setUpCell(media: data)
            cell.mediaContainerView.onTap { [weak self] in
                self?.navigateToMediaDetail(index: index)
            }
            
            cell.imagePause.onTap { [weak self] in
                self?.navigateToMediaDetail(index: index, isPlayVideo: true)
            }
        }.disposed(by: disposeBag)
        
        presenter.imagesRelay.bind { [weak self] images in
            self?.mainView.pageController.isHidden = (images.count == 1)
            self?.mainView.pageController.numberOfPages = images.count
        }.disposed(by: disposeBag)
        
        mainView.imageSlider.rx.didEndDecelerating.bind { [weak self] in
            let pageWidth = self?.mainView.imageSlider.frame.size.width ?? 1
            self?.mainView.pageController.currentPage = Int((self?.mainView.imageSlider.contentOffset.x ?? 0) / pageWidth)
        }.disposed(by: disposeBag)
        
        mainView.onClickBack = { [weak self] in
            guard let self = self else { return }
            if self.isFromEdit {
                for controller in self.navigationController!.viewControllers as Array {
                    if let myProductController = controller as? MyProductViewController {
                        if !isArchive {
                            let indexProduct = myProductController.indexProduct
                            myProductController.updateRow(at: indexProduct, data: ProductItem.fromProduct(self.presenter.product))
                        }
                        self.navigationController?.popToViewController(controller, animated: true)
                        break
                    } else if let newHomeController = controller as? NewHomeController {
                        for controller in newHomeController.viewControllerList {
                            if let productController = controller as? ProductController {
                                if UserDefaults.standard.bool(forKey: productDetailFromFeed) {
                                    UserDefaults.standard.set(false, forKey: productDetailFromFeed)
                                    let index = UserDefaults.standard.integer(forKey: indexProductDetailFromFeed)
                                    NotificationCenter.default.post(name: .handleUpdateFeed, object: nil, userInfo: ["updateProductDetailFromFeed": self.presenter.product, "indexProductDetail": index])
                                } else {
                                    let indexProduct = productController.presenter.indexProduct
                                    productController.updateRow(at: indexProduct, data: self.presenter.product)
                                }
                            }
                        }
                        self.navigationController?.popToViewController(controller, animated: true)
                        break
                    } else if let userProfileController = controller as? NewUserProfileViewController {
                        for item in userProfileController.navigationController?.viewControllers ?? [] {
                            if let profileDetail = item as? ProfileDetailViewController {
                                if UserDefaults.standard.bool(forKey: productDetailFromFeed) {
                                    UserDefaults.standard.set(false, forKey: productDetailFromFeed)
                                    let index = UserDefaults.standard.integer(forKey: indexProductDetailFromFeed)
                                    let notif = NSNotification(name: .handleUpdateFeed, object: nil, userInfo: ["updateProductDetailFromFeed": self.presenter.product, "indexProductDetail": index])
                                    profileDetail.updateRow(notif)
                                    self.navigationController?.popToViewController(profileDetail, animated: false)
                                    break
                                }
                            }
                        }
                    } else if let exploreController = controller as? ExploreViewController {
                        for item in exploreController.navigationController?.viewControllers ?? [] {
                            if let channelContent = item as? ChannelContentsController {
                                if UserDefaults.standard.bool(forKey: productDetailFromFeed) {
                                    UserDefaults.standard.set(false, forKey: productDetailFromFeed)
                                    let index = UserDefaults.standard.integer(forKey: indexProductDetailFromFeed)
                                    let notif = NSNotification(name: .handleUpdateFeed, object: nil, userInfo: ["updateProductDetailFromFeed": self.presenter.product, "indexProductDetail": index])
                                    channelContent.updateRow(notif)
                                    self.navigationController?.popToViewController(channelContent, animated: false)
                                    break
                                }
                            }
                        }
                    }
                    
                }
            } else if self.isPresent{
                self.dismiss(animated: false) {
                    for controllers in self.navigationController?.viewControllers ?? [] {
                        if let controller = controllers as? NewHomeController {
                            for item in controller.viewControllerList {
                                if let productController = item as? ProductController {
                                    let indexProduct = productController.presenter.indexProduct
                                    productController.updateRow(at: indexProduct, data: self.presenter.product)
                                }
                            }
                        }
                    }
                }
            } else if self.isUnivLink {
                self.navigationController?.popViewController(animated: false)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
        
        emptyView.onClickBack = { [weak self] in
            guard let self = self else { return }
            
            if self.isFromEdit {
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: MyProductViewController.self) {
                        self.navigationController?.popToViewController(controller, animated: true)
                        break
                    }
                }
            } else if self.isPresent{
                self.dismiss(animated: true, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        mainView.onClickTanyaPenjual = { [weak self] in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.popup.modalPresentationStyle = .overFullScreen
                self.present(self.popup, animated: false, completion: nil)
                
                self.popup.handleWhenNotLogin = {
                    self.popup.dismiss(animated: false, completion: nil)
                }
                return
            }
            guard let account = self.presenter.profileRelay.value else {
                let alertController = UIAlertController(title: "Data not found !",
                                                        message: "Seller account not found !",
                                                        preferredStyle: .alert)
                
                let loginAction = UIAlertAction(title: "OK", style: .cancel)
                
                alertController.addAction(loginAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.routeToDM(account: account)
        }
        
        mainView.onClickJadiReseller = { [weak self] in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.popup.modalPresentationStyle = .overFullScreen
                self.present(self.popup, animated: false, completion: nil)
                
                self.popup.handleWhenNotLogin = {
                    self.popup.dismiss(animated: false, completion: nil)
                }
                return
            }
            guard let account = self.presenter.profileRelay.value else {
                let alertController = UIAlertController(title: "Data not found !",
                                                        message: "Seller account not found !",
                                                        preferredStyle: .alert)
                
                let loginAction = UIAlertAction(title: "OK", style: .cancel)
                
                alertController.addAction(loginAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.checkReseller()
        }
        
        mainView.onClickUpdateStockProduct = { [weak self] in
            guard let self = self else { return }
            self.router.editProduct(self.presenter.product, isArchive: self.isArchive)
        }
        
        mainView.handleOption = { [weak self] in
            guard let self = self else { return }
            self.productActionSheet.showSheet(ProductItem.fromProduct(self.presenter.product))
        }
        
        updateBuyViewActionStyle()
        mainView.buyView.handleBuy = { [weak self] in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.popup.modalPresentationStyle = .overFullScreen
                self.present(self.popup, animated: false, completion: nil)
                self.mainView.buyView.buyButton.hideLoading()
                
                self.popup.handleWhenNotLogin = {
                    self.popup.dismiss(animated: false, completion: nil)
                }
                return
            }
            
            let quantity = Int(self.mainView.buyView.countLabel.text ?? "0")
            self.mainView.buyView.buyButton.hideLoading()
            self.router.checkout(self.presenter.product, quantity ?? 0, onProductUpdated: { product in
                self.mainView.buyView.value = 1
                self.presenter.product = product
                self.refreshView()
            })
        }
        
        mainView.buyView.handleReduce = {  [weak self] in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.popup.modalPresentationStyle = .overFullScreen
                self.present(self.popup, animated: false, completion: nil)
                self.mainView.buyView.buyButton.hideLoading()
                
                self.popup.handleWhenNotLogin = {
                    self.popup.dismiss(animated: false, completion: nil)
                }
                return
            }
            
            
            //            let stock = self.presenter.product.stock ?? 1
            if self.mainView.buyView.value > 1 {
                self.mainView.buyView.value -= 1
                self.updateBuyViewActionStyle()
            }
            //            else {
            //                self.showLongToast(message: "Jumlah barang minimal 1")
            //            }
        }
        
        mainView.buyView.handleIncrease = {  [weak self] in
            guard let self = self else { return }
            
            if !AUTH.isLogin() {
                self.popup.modalPresentationStyle = .overFullScreen
                self.present(self.popup, animated: false, completion: nil)
                self.mainView.buyView.buyButton.hideLoading()
                
                self.popup.handleWhenNotLogin = {
                    self.popup.dismiss(animated: false, completion: nil)
                }
                return
            }
            
            let stock = self.presenter.product.stock ?? 1
            
            if self.mainView.buyView.value < stock {
                self.mainView.buyView.value += 1
                self.updateBuyViewActionStyle()
            }else {
                self.showLongToast(message: "Jumlah barang tidak bisa melebihi stok tersedia", showDuration: 3.0, fadeOutDuration: 0.5)
            }
        }
        
        mainView.shopNameLabel.onTap { [weak self] in
            guard let self = self else { return }
            guard let accountId = self.presenter.product.originalAccountId ?? self.presenter.product.accountId
            else { return }
            
            let isLogin = getToken() != nil ? true : false
            guard isLogin else {
                let popup = AuthPopUpViewController(mainView: AuthPopUpView())
                popup.modalPresentationStyle = .overFullScreen
                popup.modalTransitionStyle = .crossDissolve
                popup.handleWhenNotLogin = {
                    popup.dismiss(animated: true, completion: nil)
                }
                self.present(popup, animated: true, completion: nil)
                return
            }
            
            self.router.profile(accountId, "")
        }
        
        mainView.reviewView.handleSeeAll = { [weak self] in
            guard let self = self else { return }
            self.router.review(self.idProduct, loader: self.reviewLoader)
        }
        
        mainView.reviewView.collectionView.handleItemTapped = { [weak self] (item) in
            // when item review tapped
        }
        
        mainView.reviewView.mediaCollectionView.handleItemTapped = { [weak self] (item, at) in
            guard let self = self else { return }
            var medias = self.reviewMedias ?? []
            if at == 4 { //if index tapped is 4/last index(on more)
                self.router.reviewMedia(self.idProduct, loader: self.reviewMediaLoader)
                return
            }
            if medias.count == 5 {
                medias.remove(at: 4) // remove last index
            }
            self.router.reviewDetailMedia(medias, itemAt: at)
        }
		
		if isPreview {
			mainView.updateData(product: presenter.product)
			mainView.onTapLihatLiveProduct = {
				self.isPreview = false
				self.refresh()
			}
		} else {
			refresh()
		}
		
		
		
		presenter.errorRelay.asObservable().bind { (error) in
			if !error.isEmpty {
//				self.mainView.isHidden = true
                self.mainView.bringSubviewToFront(self.emptyView)
                self.emptyView.isHidden = false
				self.emptyView.textDesc.text = error
			}
		}.disposed(by: disposeBag)
        mainView.scrollView.delegate = self
        mainView.scrollView.refreshControl = mainView.refreshControl
        mainView.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		tabBarController?.tabBar.isHidden = false
		navigationController?.navigationBar.backgroundColor = nil
	}
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        navigationController?.setNavigationBarHidden(true, animated: false)
    }
	
	override func loadView() {
        mainView.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.fillSuperview()
		view = mainView
		presenter.isActiveProduct.bind { [weak self] (value) in
			self?.mainView.updateView(isProductUser: self?.presenter.product.originalAccountId?.isItUser() ?? self?.presenter.product.accountId?.isItUser() ?? value, isPreview: self?.isPreview ?? false)
		}.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	
	override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		bindNavigationBar()
		
		tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.interactivePopGestureRecognizer?.delegate = self
	}
	
    private func updateBuyViewActionStyle(){
        let stock = presenter.product.stock ?? 1
        let current = mainView.buyView.value
        
        mainView.buyView.reduceButton.setTitleColor(current == 1 ? .placeholder : .primary, for: .normal)
//        mainView.buyView.increaseButton.setTitleColor(stock > current ? .primary : .placeholder, for: .normal)
    }
	
	private func bindNavigationBar() {
		self.navigationController?.setNavigationBarHidden(true, animated: true)
	}
    
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true
	}
	
    @objc func refresh(){
		if idProduct.count > 0 {
//			presenter.getDetailProduct(idProduct, { [weak self] in
//                self?.refreshView()
//			})
		}
	}
	
	func refreshView(){
		if let product = presenter.product{
            self.mainView.refreshControl.endRefreshing()
			mainView.updateData(product: product)
            mainView.updateView(isProductUser: self.presenter.product.originalAccountId?.isItUser() ?? self.presenter.product.accountId?.isItUser() ?? false, isPreview: isPreview)
            self.loadReview()
		}
	}
    
    func checkReseller () {
        
        presenter.checkReseller { [weak self] follower, totalPost, shopDisplay in
            guard let self = self else { return }
            
            if follower && totalPost && shopDisplay {
                let product: Product? = self.presenter.product
                
                guard let id = product?.id, let accountId = product?.accountId, let productName = product?.name, let price = product?.price, let commission = product?.commission, let imageURL = product?.medias?.first?.thumbnail?.medium else {
                    return
                }
                
                let params: ConfirmProductParams = ConfirmProductParams(id: id, accountId: accountId, productName: productName, price: price, commission: commission, imageURL: imageURL)
                let controller = ResellerConfirmProductUIFactory.create(with: params) { [weak self] in
                    guard let self = self else { return }
                    self.refresh()
                }
                
                controller.bindNavigationBar(.get(.productReseller), true)
                self.navigationController?.displayShadowToNavBar(status: true, .whiteSmoke)
                self.navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = ResellerValidatorUIFactory.create()
                self.present(controller, animated: false)
            }
        }
    }
    
    func routeToDM(account: Profile) {
        guard let userId = account.id, !userId.isEmpty else {
            DispatchQueue.main.async {
                KKLoading.shared.hide()
                Toast.share.show(message: "Error: User not found..")
            }
            return
        }
        
        DispatchQueue.main.async {
            KKLoading.shared.hide() {
                let user = TXIMUser(userID: userId, userName: account.name ?? "", faceURL: account.photo ?? "", isVerified: account.isVerified ?? false)
                showIMConversation?(user)
            }
        }
    }
    
    func onNavigateToChannel() {
    }
    
    func onNavigateToChannel(channelUrl: String) {
        
    }
    
    func routeToFakeDM(account: Profile) {
        
    }
    
    func leaveFakeDM(accountId: String) {
        
    }
    
    func updateUsername() {
        if let product = presenter.product{
            self.refreshView()
            mainView.updateUsername(product: product)
        }
    }
}

extension ProductDetailController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        animateNavbar(scrollView)
    }
    
    private func animateNavbar(_ scrollView: UIScrollView) {
        let visibleNavbar = scrollView.contentOffset.y > 300
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.mainView.navBarContainer.alpha = visibleNavbar ? 1 : 0
                self.mainView.buttonLeft.backgroundColor = visibleNavbar ? .white : .black25
                self.mainView.buttonRight.backgroundColor = visibleNavbar ? .white : .black25
                
                if  visibleNavbar {
                    let iconArrowLeftBlack = UIImage(named: .get(.arrowLeftBlack))?.withRenderingMode(.alwaysOriginal)
                    let iconKebab = UIImage(named: .get(.iconEllipsis))?.withRenderingMode(.alwaysOriginal)
                    self.mainView.buttonLeft.setImage(iconArrowLeftBlack, for: .normal)
                    self.mainView.buttonRight.setImage(iconKebab, for: .normal)
                } else {
                    let iconArrowLeft = UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysOriginal)
                    let iconKebab = UIImage(named: .get(.iconKebab))?.withRenderingMode(.alwaysOriginal)
                    self.mainView.buttonLeft.setImage(iconArrowLeft, for: .normal)
                    self.mainView.buttonRight.setImage(iconKebab, for: .normal)
                }
            }
        }
    }
}

extension ProductDetailController : ProductActionSheetDelegate {
	
	func activeSuccess() {
		self.refresh()
	}
	
	func activeError(errorMsg: String) {
			self.presenter.errorRelay.accept(errorMsg)
	}
	
	func archiveSuccess() {
		self.refresh()
		self.router.toArchive()
	}
	
	func archiveError(errorMsg: String) {
		self.presenter.errorRelay.accept(errorMsg)
	}
	
    func deleteSuccess(_ index: Int) {
		self.deleteCallback()
	}
	
	func deleteError(errorMsg: String) {
		self.presenter.errorRelay.accept(errorMsg)
	}
	
    func resellerUpdated() {
        self.navigationController?.popViewController(animated: true)
        handleRefreshList?()
    }
}

extension ProductDetailController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: collectionView.frame.size.height)
    }
}

let productDetailFromFeed = "productDetailFromFeed"
let indexProductDetailFromFeed = "indexProductDetailFromFeed"


// MARK: - for Review Section
extension ProductDetailController {
    private func loadReview(){
        reviewLoader.load(request: ReviewPagedRequest(productId: idProduct, size: 2, isPublic: !AUTH.isLogin())) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch(result){
                case .success(let review):
                    self.mainView.loadReview(review)
                    self.loadMediaReview()
                    break
                case .failure(let error):
                    print("*** failed load review \(error)")
                    if let error = error as? RemoteReviewLoader.Error {
                        if error == .noData {
                            break
                        }
                    }
                    
                    self.showToast(message: "Gagal memuat review")
                    break
                }
            }
        }
    }
    
    private func loadMediaReview(){
        reviewMediaLoader.load(request: ReviewPagedRequest(productId: idProduct, size: 5, isPublic: !AUTH.isLogin())) { [weak self] (result) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch(result){
                case .success(let data):
                    self.reviewMedias = data.content
                    self.mainView.loadMediaReview(data.content)
                    break
                case .failure(let error):
                    print("*** failed load media review \(error)")
                    
                    if let error = error as? RemoteReviewMediaLoader.Error {
                        if error == .noData {
                            break
                        }
                    }
                    
                    Toast.share.show(message: "Gagal memuat media review")
                    break
                }
            }
        }
    }
}
