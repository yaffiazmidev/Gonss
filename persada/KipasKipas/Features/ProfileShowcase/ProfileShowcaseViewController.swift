//
//  ProfileShowcaseViewController.swift
//  KipasKipasProfileUI
//
//  Created by DENAZMI on 24/12/23.
//

import UIKit

class ProfileShowcaseViewController: UIViewController {

    lazy var mainView: ProfileShowcaseView = {
        let view = ProfileShowcaseView().loadViewFromNib() as! ProfileShowcaseView
        view.delegate = self
        return view
    }()
    
    var productItems: [ShopViewModel] = [] {
        didSet {
            mainView.productItems = productItems
        }
    }
    
    var userId: String = ""
    var handleUpdateCollectionHeight: ((CGFloat) -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = mainView
    }
    
    func reloadProducts() {
        mainView.collectionView.reloadData()
    }
}

extension ProfileShowcaseViewController: ProfileShowcaseViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleUpdateCollectionHeight?(mainView.collectionView.frame.height)
    }
    
    func didSelectedProduct(by item: ShopViewModel) {
        let detailController = ProductDetailFactory.createProductDetailController(
            dataSource: Product(id: item.id, name: item.name, price: item.price, totalSales: item.totalSales)
        )
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
}
