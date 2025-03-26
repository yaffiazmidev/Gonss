//
//  SearchProductViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 29/01/23.
//

import UIKit

class SearchProductViewController: UIViewController {
    
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var filterAllUserButton: UIButton!
    @IBOutlet weak var filterVerifiedButton: UIButton!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterContainerStackView: UIStackView!
    @IBOutlet weak var categoryFlagLabel: UILabel!
    
    private var products: [FilterProductViewModel] = [FilterProductViewModel]()
    private var delegate: FilterProductControllerDelegate
    private var requestPage: Int = 0
    private var isVerifiedProduct: Bool = false
    private var categoryProduct: CategoryShopItem?
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    init(delegate: FilterProductControllerDelegate,
         categoryProduct: CategoryShopItem? = nil)
    {
        self.delegate = delegate
        self.categoryProduct = categoryProduct
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        searchBarTextField.delegate = self
        setupCollectionView()
        handleActions()
        searchBarTextField.addTarget(self, action: #selector(didEditingChanged(_:)), for: .editingChanged)
        
        categoryFlagLabel.isHidden = categoryProduct == nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    @objc private func didEditingChanged(_ textField: UITextField) {
        guard let keyword = textField.text, !keyword.isEmpty else {
            filterContainerStackView.isHidden = true
            products = []
            collectionView.backgroundView = nil
            collectionView.reloadData()
            return
        }
        
        requestPage = 0
        DispatchQueue.main.asyncDeduped(target: self, after: 0.5) { [weak self] in
            if keyword.count >= 2 {
                self?.requestSearchProduct(with: keyword)
            }
        }
    }
    
    private func requestSearchProduct(with search: String) {
        let request = FilterProductRequest(
            productCategoryId: categoryProduct?.id,
            isVerified: isVerifiedProduct,
            keyword: search,
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
    }
    
    private func setupPinterestLayout() {
        let layout = DENCollectionViewLayout()
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.columnCount = 2
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = layout
    }
    
    private func handleActions() {
        cancelLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
        
        filterAllUserButton.onTap { [weak self] in
            guard let self = self else { return }
            self.selectFilter(isVerified: false)
            self.requestSearchProduct(with: self.searchBarTextField.text ?? "")
        }
        
        filterVerifiedButton.onTap { [weak self] in
            guard let self = self else { return }
            self.selectFilter(isVerified: true)
            self.requestSearchProduct(with: self.searchBarTextField.text ?? "")
        }
    }
    
    @objc private func handleRefresh() {
        requestPage = 0
        let text = searchBarTextField.text ?? ""
        requestSearchProduct(with: text)
    }
    
    private func handleSearchResultTextAttribute(text: String) {
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: "Hasil pencarian ", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 13), NSAttributedString.Key.foregroundColor: UIColor.grey ])
        
        attributedText.append(NSMutableAttributedString(string: "“\(text)” ", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.bold, size: 13), NSAttributedString.Key.foregroundColor: UIColor.black ]))
        
        attributedText.append(NSMutableAttributedString(string: "dalam kategori ", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 13), NSAttributedString.Key.foregroundColor: UIColor.grey ]))
        
        attributedText.append(NSMutableAttributedString(string: "\(categoryProduct?.name ?? "")", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 13), NSAttributedString.Key.foregroundColor: UIColor.black ]))
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        
        categoryFlagLabel.attributedText = attributedText
    }
}

extension SearchProductViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension SearchProductViewController: UICollectionViewDataSource {
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

extension SearchProductViewController: UIGestureRecognizerDelegate {}

extension SearchProductViewController: DENCollectionViewDelegateLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = products[indexPath.item]
        let detailController = ProductDetailFactory.createProductDetailController(
            dataSource: Product(id: product.id, name: product.name, price: product.price, totalSales: product.totalSales)
        )
        detailController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(detailController, animated: true)
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
        }
        height = (height * percent) + 200
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}

extension SearchProductViewController: FilterProductView, FilterProductLoadingView, FilterProductLoadingErrorView {
    func display(_ viewModel: [FilterProductViewModel]) {
        handleSearchResultTextAttribute(text: searchBarTextField.text ?? "")
//        if viewModel.isEmpty {
//            filterContainerStackView.isHidden = viewModel.isEmpty
//        } else {
            filterContainerStackView.isHidden = false
//        }
        
        products = viewModel
        refreshControl.endRefreshing()
        collectionView.reloadData()
        if viewModel.isEmpty && searchBarTextField.text ?? "" != "" && products.isEmpty {
            collectionView.emptyView(
                isEmpty: true,
                title: "Tidak ada produk yang sesuai dengan pencarian ini\nCoba kata kunci lain atau reset filter",
                subtitle: "Coba kata kunci lain") { [weak self] in
                    self?.searchBarTextField.text = ""
                    self?.searchBarTextField.becomeFirstResponder()
                    self?.products = []
                    self?.collectionView.backgroundView = nil
                    self?.collectionView.reloadData()
                }
        } else {
            collectionView.backgroundView = nil
        }
    }
    
    func display(_ viewModel: FilterProductLoadingViewModel) {
    }
    
    func display(_ viewModel: FilterProductLoadingErrorViewModel) {

    }
}
