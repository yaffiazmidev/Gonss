//
//  CategoryDetailViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 30/01/23.
//

import UIKit

class CategoryDetailViewController: UIViewController {
    
    @IBOutlet weak var filterAllUserButton: UIButton!
    @IBOutlet weak var filterVerifiedButton: UIButton!
    @IBOutlet weak var filterContainerStackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var searchProductButton: UIButton = {
        let button: UIButton = UIButton(type: .custom)
        let image = UIImage(named: .get(.search))?.withRenderingMode(.alwaysTemplate)
        button.setImage(image!, for: .normal)
        button.tintColor = .black
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(handleSearchProduct), for: .touchUpInside)
        return button
    }()
    
    private var categoryProduct: CategoryShopItem
    private var products: [FilterProductViewModel] = [FilterProductViewModel]()
    private var delegate: FilterProductControllerDelegate
    private var requestPage: Int = 0
    private var isVerifiedProduct: Bool = false
    private var firstRequest: Bool = true
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    init(delegate: FilterProductControllerDelegate, categoryProduct: CategoryShopItem) {
        self.delegate = delegate
        self.categoryProduct = categoryProduct
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        setupView()
        setupCollectionView()
        handleActions()
        requestCategoryDetailProduct()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.displayShadowToNavBar(status: true, .whiteSmoke)
        navigationController?.hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.displayShadowToNavBar(status: false)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupView() {
        bindNavigationBar(categoryProduct.name)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchProductButton)
    }
    
    private func requestCategoryDetailProduct() {
        let request = FilterProductRequest(
            productCategoryId: categoryProduct.id,
            isVerified: isVerifiedProduct,
            page: requestPage,
            size: 10
        )
        
        delegate.didRequestFilterProduct(request: request)
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        collectionView.registerXibCell(ShopProductCollectionViewCell.self)
        setupPinterestLayout()
    }
    
    private func selectFilter(isVerified: Bool) {
        isVerifiedProduct = isVerified
        filterAllUserButton.backgroundColor = !isVerified ? .secondary : .white
        filterAllUserButton.setTitleColor(!isVerified ? .white : .grey, for: .normal)
        filterVerifiedButton.backgroundColor = isVerified ? .secondary : .white
        filterVerifiedButton.setTitleColor(isVerified ? .white : .grey, for: .normal)
        requestCategoryDetailProduct()
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.columnCount = 2
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
    }
    
    private func handleActions() {
        
        filterAllUserButton.onTap { [weak self] in
            guard let self = self else { return }
            self.requestPage = 0
            self.selectFilter(isVerified: false)
            self.firstRequest = false
        }
        
        filterVerifiedButton.onTap { [weak self] in
            guard let self = self else { return }
            self.requestPage = 0
            self.selectFilter(isVerified: true)
            self.firstRequest = false
        }
    }
    
    @objc private func handleRefresh() {
        requestPage = 0
        requestCategoryDetailProduct()
    }
    
    private func navigateSearchProduct(item: CategoryShopItem) {
        let detailController = SearchProductUIFactory.create(isPublic: !AUTH.isLogin(), categoryShop: item)
        let navigate = UINavigationController(rootViewController: detailController)
        navigate.modalPresentationStyle = .fullScreen
        navigate.modalTransitionStyle = .crossDissolve
        present(navigate, animated: false)
    }
    
    private func navigateProductDetail(product: Product) {
        let selectedProduct = Product(id: product.id, name: product.name, price: product.price, totalSales: product.totalSales)
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: selectedProduct)
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @objc private func handleSearchProduct() {
        self.navigateSearchProduct(item: self.categoryProduct)
    }
}

extension CategoryDetailViewController: UIGestureRecognizerDelegate {}

extension CategoryDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ShopProductCollectionViewCell.self, for: indexPath)
        let item = products[indexPath.item]
        cell.setupViewForFilter(item)
        return cell
    }
}

extension CategoryDetailViewController: DENCollectionViewDelegateLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        let item = Product(id: product.id, name: product.name, price: product.price, totalSales: product.totalSales)
        navigateProductDetail(product: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = products[indexPath.item]
        let heightImage = item.metadataHeight
        let widthImage = item.metadataWidth
        let width = collectionView.frame.size.width - 4
        let scaler = width / widthImage
        let percent = Double((10 - ((indexPath.item % 2) + 1))) / 10
        var height = heightImage * scaler
        if height > 500 {
            height = 500
        } else if height < 500 {
            height = 400
        }
        height = (height * percent) + 200
        return CGSize(width: width, height: height)
    }
}

extension CategoryDetailViewController: FilterProductView, FilterProductLoadingView, FilterProductLoadingErrorView {
    func display(_ viewModel: [FilterProductViewModel]) {
        if requestPage == 0 {
            products = viewModel
        } else {
            products.append(contentsOf: viewModel)
        }
        
        var emptyString = ""
        if viewModel.isEmpty && firstRequest {
            filterContainerStackView.isHidden = true
            emptyString = "Belum ada product untuk kategori ini"
        } else {
            filterContainerStackView.isHidden = false
            emptyString = "Tidak ada produk dari verified user"
        }
        
        guard !viewModel.isEmpty else {
            collectionView.emptyView(isEmpty: true, title: emptyString)
            refreshControl.endRefreshing()
            collectionView.reloadData()
            return
        }
        collectionView.emptyView(isEmpty: false)
        requestPage += 1
        refreshControl.endRefreshing()
        collectionView.reloadData()
    }
    
    func display(_ viewModel: FilterProductLoadingViewModel) {
    
    }
    
    func display(_ viewModel: FilterProductLoadingErrorViewModel) {

    }
}
