//
//  ShopViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI
import KipasKipasShared
import KipasKipasDirectMessageUI

enum ShopSection: Int, CaseIterable {
    case header                 = 0
    case banner                 = 1
    case menu                   = 2
    case specialDiscount        = 3
    case brandPromo             = 4
    case todayPromo             = 5
    case selectedShop           = 6
    case bestCollectionPromo    = 7
    case onlyForYou             = 8
    case productCategory        = 9
    case product                = 10
}

protocol ShopViewControllerDelegate: AnyObject {
    func displayProductSpecialDiscount(with items: [RemoteProductEtalaseData])
    func displayErrorGetProductSpecialDiscount(with message: String)
    func displayStores(with items: [RemoteStoreItemData])
    func displayErrorGetStores(with message: String)
}

class ShopViewController: UIViewController {
    
    @IBOutlet weak var scanQRCodeIconImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBarContainerStackView: UIStackView!
    @IBOutlet weak var mailContainerStackView: UIStackView!
    @IBOutlet weak var notifContainerStackView: UIStackView!
    @IBOutlet weak var cartContainerStackView: UIStackView!
    @IBOutlet weak var menuContainerStackView: UIStackView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    private let viewModel: IKKShopViewModel
    private let delegate: ShopDelegate
    private var products: [ShopViewModel] = []
    private var categoryItems: [CategoryShopItem] = []
    private var recomProducts: [RecommendShopViewModel] = []
    private var productSpecialDiscount: [RemoteProductEtalaseData] = []
    private var selectedStores: [RemoteStoreItemData] = []
    private var brands: [String] = [
        "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/img_promo1.png",
        "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/img_promo2.png",
        "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/img_promo3.png",
        "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/img_promo4.png"
    ]
    private var requestPage = 0
    private var isProductLastPage = false
    
    init(delegate: ShopDelegate, viewModel: IKKShopViewModel) {
        self.delegate = delegate
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupCollectionView()
        handleOnTap()
//        delegate.didCheckPhotoLibraryPermissionStatus()
        defaultRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.refreshControl = refreshControl
        collectionView.accessibilityIdentifier = "collectionView-ShopControllercollectionView"
        
        collectionView.registerXibCell(ShopHeaderCollectionViewCell.self)
        collectionView.registerXibCell(ShopBannerCollectionViewCell.self)
        collectionView.registerXibCell(ShopMenuCollectionViewCell.self)
        collectionView.registerXibCell(ShopSpecialDiscountCollectionViewCell.self)
        collectionView.registerXibCell(ShopProductItemCollectionViewCell.self)
        collectionView.registerXibCell(ShopBrandPromoCollectionViewCell.self)
        collectionView.registerXibCell(ShopSelectedShopCollectionViewCell.self)
        collectionView.registerXibCell(ShopProductCollectionViewCell.self)
        collectionView.registerXibCell(ShopProductCategoryCollectionViewCell.self)
        
        setupPinterestLayout()
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.columnCounts = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2]
        layout.minimumColumnSpacings = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        layout.minimumInteritemSpacings = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        layout.sectionInsets = [ .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero,
            .init(horizontal: 16, vertical: 0),
        ]
        collectionView.collectionViewLayout = layout
    }
    
    private func requestShop(page: Int, size: Int) {
        let requestShop = ShopRequest(page: page, size: size)
        delegate.didRequestShop(request: requestShop)
    }
    
    private func defaultRequest() {
        viewModel.requestProductSpecialDiscount()
        viewModel.requestSelectedStore()
        delegate.didRequestCategoryShop(request: CategoryShopRequest(page: requestPage, size: 12))
        //        delegate.didRequestRecommendShop()
        requestShop(page: 0, size: 10)
    }
    
    private func handleOnTap() {
        searchBarContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.navigateToSearchProduct()
        }
        
        scanQRCodeIconImageView.onTap { [weak self] in
            guard let self = self else { return }
            self.navigateToKKQRCamera()
        }
        
        cartContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            let vc = CustomPopUpViewController(
                title: "Fitur sedang dalam proses pengembangan.",
                description: "Kami sedang menyempurnakan fitur ini, bersiaplah untuk pengalaman terbaik.",
                iconImage: UIImage(named: "img_in_progress"),
                iconHeight: 99
            )
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
        
        mailContainerStackView.onTap { [weak self] in
            guard let self = self else { return }
            self.navigateToDM()
        }
    }
    
    private func navigateToDM() {
        let isLogin = getToken() != nil
        
        guard isLogin else {
            let popup = AuthPopUpViewController(mainView: AuthPopUpView())
            popup.modalPresentationStyle = .overFullScreen
            popup.modalTransitionStyle = .crossDissolve
            popup.handleWhenNotLogin = { [weak self] in
                guard let self = self else { return }
                popup.dismiss(animated: true, completion: nil)
            }
            present(popup, animated: true, completion: nil)
            return
        }
        
        showDirectMessage?()
    }
    
    func navigateToShop(_ id: String) {
        
        if id == getIdUser() {
            let storeController = MyProductFactory.createMyProductController(true)
            storeController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(storeController, animated: true)
        } else {
            var profile = Profile.emptyObject()
            profile.id = id
            let storeController = AnotherProductFactory.createAnotherProductController(account: profile)
            storeController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(storeController, animated: false)
        }
    }
}

extension ShopViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { ShopSection.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard ShopSection(rawValue: section) != .product else { return products.count }
        guard ShopSection(rawValue: section) != .header else { return 0 } // hide, delete if neeed to show again!
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = ShopSection(rawValue: indexPath.section) else { return UICollectionViewCell () }
        switch section {
        case .header:
            let cell = collectionView.dequeueReusableCell(ShopHeaderCollectionViewCell.self, for: indexPath)
            return cell
        case .banner:
            let cell = collectionView.dequeueReusableCell(ShopBannerCollectionViewCell.self, for: indexPath)
            let baseURL = "https://asset.kipaskipas.com/assets_public/mobile/ios/shop/"
            cell.banners = [
                "\(baseURL)banner1.png", "\(baseURL)banner2.png",
                "\(baseURL)banner3.png", "\(baseURL)banner4.png"
            ]
            return cell
        case .menu:
            let cell = collectionView.dequeueReusableCell(ShopMenuCollectionViewCell.self, for: indexPath)
            cell.categories = categoryItems
            cell.handleClickAllCategory = { [weak self] in
                guard self != nil else { return }
                self?.handleNavigateAllCategory()
            }
            
            cell.handleClickDetailCategory = { [weak self] item in
                guard self != nil else { return }
                self?.handleNavigateDetailCategory(item)
            }
            return cell
        case .specialDiscount:
            let cell = collectionView.dequeueReusableCell(ShopSpecialDiscountCollectionViewCell.self, for: indexPath)
            cell.products = productSpecialDiscount
            cell.handleClickDetailProduct = { [weak self] item in
                guard self != nil else { return }
                self?.navigateToDetailProductEtalase(with: item)
            }
            return cell
        case .brandPromo:
            let cell = collectionView.dequeueReusableCell(ShopBrandPromoCollectionViewCell.self, for: indexPath)
            cell.brands = brands
            return cell
        case .todayPromo:
            let cell = collectionView.dequeueReusableCell(ShopHeaderCollectionViewCell.self, for: indexPath)
            return cell
        case .selectedShop:
            let cell = collectionView.dequeueReusableCell(ShopSelectedShopCollectionViewCell.self, for: indexPath)
            cell.stores = selectedStores
            cell.handleDidSelecStore = { [weak self] store in
                guard let self = self else { return }
                self.navigateToShop(store?.accountId ?? "")
            }
            return cell
        case .bestCollectionPromo:
            let cell = collectionView.dequeueReusableCell(ShopHeaderCollectionViewCell.self, for: indexPath)
            return cell
        case .onlyForYou:
            let cell = collectionView.dequeueReusableCell(ShopHeaderCollectionViewCell.self, for: indexPath)
            return cell
        case .productCategory:
            let cell = collectionView.dequeueReusableCell(ShopProductCategoryCollectionViewCell.self, for: indexPath)
            cell.collectionView.isHidden = true
            cell.categories = categoryItems
            return cell
        case .product:
            let cell = collectionView.dequeueReusableCell(ShopProductCollectionViewCell.self, for: indexPath)
            let item = products[indexPath.item]
            cell.setupViewForShop(item)
            return cell
        }
    }
}

extension ShopViewController: DENCollectionViewDelegateLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard ShopSection(rawValue: indexPath.section) == .product else { return }
        navigateToDetailProduct(with: products[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard ShopSection(rawValue: indexPath.section) == .product else { return }
        
        if indexPath.item == products.count - 1 && (requestPage > 0 && !isProductLastPage) {
            requestShop(page: requestPage, size: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = ShopSection(rawValue: indexPath.section) else { return CGSize() }
        
        switch section {
        case .header:
            return .init(width: collectionView.frame.width, height: 77)
        case .banner:
            return .init(width: collectionView.frame.width, height: 138)
        case .menu:
            return .init(width: collectionView.frame.width, height: 176)
        case .specialDiscount:
            return .init(width: collectionView.frame.width, height: 310) // - Ajust form 325 to 290
        case .brandPromo:
            return .init(width: collectionView.frame.width, height: 338)
//        case .todayPromo:
//            break
        case .selectedShop:
            return .init(width: collectionView.frame.width, height: 298)
//        case .bestCollectionPromo:
//            break
//        case .onlyForYou:
//            break
        case .productCategory:
            return .init(width: collectionView.frame.width, height: 46 /*91*/)
        case .product:
            guard !products.isEmpty else { return CGSize() }
            let item = products[indexPath.item]
            let heightImage = item.metadataHeight ?? 1028
            let widthImage = item.metadataWidth ?? 1028
            let width = collectionView.frame.size.width - 4
            let scaler = width / widthImage
            let percent = Double((10 - ((indexPath.item % 3) + 1))) / 10
            var height = heightImage * scaler
            if height > 500 {
                height = 500
            }
            height = (height * percent) + 200
            return CGSize(width: width, height: height)
        default:
            return .init(width: collectionView.frame.width, height: 0)
        }
    }
}

extension ShopViewController: ShopViewControllerDelegate {
    func displayProductSpecialDiscount(with items: [RemoteProductEtalaseData]) {
        productSpecialDiscount = items
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
        reloadSection(for: .specialDiscount)
    }
    
    func displayErrorGetProductSpecialDiscount(with message: String) {
        print(message)
    }
    
    func displayStores(with items: [RemoteStoreItemData]) {
        selectedStores = items
        reloadSection(for: .selectedShop)
    }
    
    func displayErrorGetStores(with message: String) {
        
    }
}


extension ShopViewController: CategoryShopView, CategoryShopLoadingView, CategoryShopLoadingErrorView {
    func display(_ viewModel: CategoryShopViewModel) {
//        var limitCategories = Array(viewModel.items.prefix(11))
//        let otherCategory = CategoryShopItem(id: "others", name: "Lainnya", sequence: 12, totalProduct: 0, icon: "ic_candy_box", description: "Lainnya")
//        limitCategories.append(otherCategory)
        categoryItems = viewModel.items
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
        reloadSection(for: .productCategory)
        reloadSection(for: .menu)
    }
    
    func display(_ viewModel: CategoryShopLoadingViewModel) {
        guard viewModel.isLoading else { return }
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
    
    func display(_ viewModel: CategoryShopLoadingErrorViewModel) {
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
}

extension ShopViewController: RecommendShopView, RecommendShopLoadingView, RecommendShopLoadingErrorView {
    func display(_ viewModel: [RecommendShopViewModel]) {
        recomProducts = viewModel
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
        //        reloadSection(for: .productRecom)
    }
    
    func display(_ viewModel: RecommendShopLoadingViewModel) {
        guard viewModel.isLoading else { return }
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
    
    func display(_ viewModel: RecommendShopLoadingErrorViewModel) {
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
}

extension ShopViewController: ShopView, ShopLoadingView, ShopLoadingErrorView {
    func display(_ viewModel: [ShopViewModel]) {
        products = requestPage > 0 ? products + viewModel : viewModel
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
        reloadSection(for: .product)
        requestPage += 1
        isProductLastPage = requestPage > 0 && viewModel.isEmpty
    }
    
    func display(_ viewModel: ShopLoadingViewModel) {
        guard viewModel.isLoading else { return }
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
    
    func display(_ viewModel: ShopLoadingErrorViewModel) {
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
}

extension ShopViewController: PermissionPhotoLibraryPreferencesView {
    func display(_ viewModel: PermissionPhotoLibraryPreferencesViewModels) {
        //        isPermissionGalleryAllowed = viewModel.item.isPermissionAllowed
    }
}

extension ShopViewController {
    @objc func handleRefresh() {
        defaultRequest()
        DispatchQueue.main.async { self.collectionView.reloadData() }
        DispatchQueue.main.async { self.refreshControl.endRefreshing() }
    }
    
    private func handleNavigateAllCategory() {
        let controller = CategoryShopUIFactory.create(isPublic: !AUTH.isLogin())
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleNavigateDetailCategory(_ item: CategoryShopItem) {
        let controller = CategoryDetailUIFactory.create(isPublic: !AUTH.isLogin(), categoryProduct: item)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func handleNavigateDetailRecommend(_ product: RecommendShopViewModel) {
        let controller = ProductDetailFactory.createProductDetailController(dataSource: Product(id: product.id, name: product.name, price: product.price, totalSales: product.totalSales))
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func routeToSetting() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    private func reloadSection(for section: ShopSection) {
        DispatchQueue.main.async {
            self.collectionView.customReloadSections([section.rawValue])
        }
    }
    
    private func navigateToPrivacyPolicy() {
        let privacyPolicyId = "#1674017117382-35859120-e967"
        let url = .get(.kipasKipasPrivacyPolicyUrl) + privacyPolicyId
        let browserController = AlternativeBrowserController(url: url)
        browserController.bindNavigationBar(.get(.kebijakanPrivasi), false)
        
        let navigate = UINavigationController(rootViewController: browserController)
        navigate.modalPresentationStyle = .fullScreen
        present(navigate, animated: true, completion: nil)
    }
    
    func getProducts() -> Int {
        return products.count
    }
    
    private func navigateToDetailProduct(with item: ShopViewModel) {
        let detailController = ProductDetailFactory.createProductDetailController(
            dataSource: Product(id: item.id, name: item.name, price: item.price, totalSales: item.totalSales)
        )
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    private func navigateToDetailProductEtalase(with item: RemoteProductEtalaseData) {
        let detailController = ProductDetailFactory.createProductDetailController(
            dataSource: Product(id: item.id, name: item.name, price: item.price, totalSales: item.totalSales)
        )
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    private func navigateToKKQRCamera() {
        let vc = KKQRCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.handleWhenExtracted = { [weak self] result in
            guard let self = self, let nav = self.navigationController else { return }
            if result.type == .shop {
                let vc = ProductDetailFactory.createProductDetailController(dataSource: Product(id: result.id))
                nav.pushViewController(vc, animated: true)
            }
        }
        
        present(vc, animated: true)
    }
    
    private func navigateToSearchProduct() {
        let controller = SearchProductUIFactory.create(isPublic: !AUTH.isLogin())
        let navigate = UINavigationController(rootViewController: controller)
        navigate.modalPresentationStyle = .fullScreen
        navigate.hidesBottomBarWhenPushed = true
        present(navigate, animated: true, completion: nil)
    }
}

fileprivate extension UICollectionView {
    func customReloadSections(_ sections: IndexSet) {
        var valid = true
        for section in sections {
            if numberOfItems(inSection: section) < 1 {
                valid = false
                break
            }
        }
        
        if valid {
            reloadSections(sections)
        } else {
            reloadData()
        }
    }
}
