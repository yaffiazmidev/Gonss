//
//  AnotherProductController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 16/06/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking
import KipasKipasShared

final class AnotherProductController: UIViewController, AlertDisplayer {
    let mainView: AnotherProductView
    private var router: AnotherProductRouting!
    private var flowLayout: DENCollectionViewLayout!
    private var emptyViewData: CustomEmptyViewData?
    
    var listLoader: RemoteProductListLoader!
    var searchLoader: RemoteProductSearchLoader!
    
    private var products: [ProductItem] = []
    private var page: Int = 0
    private var totalPages: Int = 0
    private var onSearch: Bool = false
    private var onLoading: Bool = false
    
    private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
    
    private var productID = ""
    private var product : Product?
    private var image : UIImage?
    private var data : Data?
    var account: Profile?
    
    required init(mainView: AnotherProductView) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
        router = AnotherProductRouter(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //		bindNavigationBar(String.get(.shopping))
        title = .get(.shopping)
        
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.backgroundColor = .white

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)), style: .plain, target: self, action: #selector(self.back))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    deinit{
        emptyViewData = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.hideKeyboardWhenTappedAround()
        setupCollectionView()
        refreshUI()
    }
    
    override func loadView() {
        view = mainView
        mainView.searchBarTextField.delegate = self
        mainView.delegate = self
        let clearGesture = UITapGestureRecognizer(target: self, action: #selector(clearTextField(tapGestureRecognizer:)))
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(clearTextField(tapGestureRecognizer:)))
        mainView.searchBarTextField.rightView?.addGestureRecognizer(clearGesture)
        mainView.searchBarCancel.addGestureRecognizer(cancelGesture)
        view.backgroundColor = .white
    }
    
    @objc
    func clearTextField(tapGestureRecognizer: UITapGestureRecognizer){
        if !mainView.searchBarTextField.text.isNilOrEmpty {
            mainView.searchBarTextField.text = ""
            mainView.updateSearchView(isEmpty: true)
            emptyViewData = nil
            refreshUI()
        }
    }
    
    func setupCollectionView() {
        self.mainView.collectionView.delegate = self
        self.mainView.collectionView.dataSource = self
        
        setupPinterestLayout()
    }
    
    private func setupPinterestLayout() {
        flowLayout = DENCollectionViewLayout()
        flowLayout.columnCount = 2
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumColumnSpacing = 0
        mainView.collectionView.showsVerticalScrollIndicator = false
        mainView.collectionView.alwaysBounceVertical = true
        mainView.collectionView.collectionViewLayout = flowLayout
        updateFlowLayoutHeight()
    }
    
    private func updateFlowLayoutHeight(){
        flowLayout.footerHeight = products.isEmpty ? mainView.collectionView.frame.height - flowLayout.headerHeight : 0
    }
    
    @objc private func back() {
        self.router.routeTo(.dismiss)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    func refreshUI() {
        mainView.searchBarTextField.text = nil
        onSearch = false
        clearData()
        loadList()
    }
    
    private func clearData(){
        self.page = 0
        self.totalPages = 0
        self.products = []
        self.emptyViewData = nil
        self.mainView.collectionView.reloadData()
    }
}

//MARK: - Loader Implementataion
extension AnotherProductController {    
    private func loadList(){
        let request = ProductListLoaderRequest(accountId: account?.id ?? "", page: page, type: ProductType.all.rawValue)
        self.onLoading = true
        listLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                DispatchQueue.main.async {
                    self.onLoading = false
                    self.updateProducts(item)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.onLoading = false
                    Toast.share.show(message: self.getErrorMessage(error))
                    self.emptyViewData = CustomEmptyViewData(title: "Gagal memuat data", message: self.getErrorMessage(error))
                    self.updateFlowLayoutHeight()
                    self.mainView.refreshController.endRefreshing()
                    self.mainView.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadSearch(_ text: String){
        let request = ProductSearchLoaderRequest(accountId: account?.id ?? "", page: page, type: ProductType.all.rawValue, keyword: text)
        self.onLoading = true
        searchLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                DispatchQueue.main.async {
                    self.onLoading = false
                    self.updateProducts(item)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.onLoading = false
                    let message = "\"\(self.mainView.searchBarTextField.text ?? "")\" " + .get(.notFoundNameProduct) + "\nError: \(self.getErrorMessage(error))"
                    Toast.share.show(message: message)
                    self.emptyViewData = CustomEmptyViewData(title: "Gagal memuat data", message: message)
                    self.updateFlowLayoutHeight()
                    self.mainView.refreshController.endRefreshing()
                    self.mainView.collectionView.reloadData()
                }
            }
        }
    }
    
    private func updateProducts(_ result: ProductArrayItem){
        if result.data.isEmpty {
            if onSearch {
                let message = "\"\(self.mainView.searchBarTextField.text ?? "")\" " + .get(.notFoundNameProduct)
                Toast.share.show(message: message)
                emptyViewData = CustomEmptyViewData(icon: .get(.iconNotFoundBold),title: "Produk tidak ditemukan", message: message)
            }else {
                emptyViewData = CustomEmptyViewData(message: .get(.produkTidakTersediaDeskripsi))
            }
        }
        self.page == 0 ? self.products = result.data : self.products.append(contentsOf: result.data)
        self.totalPages = result.totalPages
        self.updateFlowLayoutHeight()
        self.mainView.refreshController.endRefreshing()
        self.mainView.collectionView.reloadData()
    }
    
    private func getErrorMessage(_ error: Error) -> String {
        if let error = error as? KKNetworkError {
            switch error {
            case .connectivity:
                return "Gagal menghubungkan ke server"
            case .invalidData:
                return "Gagal memuat data"
            case .responseFailure(let error):
                return "Gagal memuat data\n\(error.message)"
            default:
                return error.localizedDescription
            }
        }
        
        return error.localizedDescription
    }
    
}

// MARK: - AnotherProductViewDelegate
extension AnotherProductController: AnotherProductViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(ProductViewCell.self, for: indexPath)
        cell.setupView(products[indexPath.row], isSelf: false)
        cell.optionMore.onTap { [weak self] in
            guard let self = self else { return }
            //				self.decideSheetOption(product: items[row])
            self.image = cell.productImageView.image
            self.data = cell.productImageView.image?.jpegData(compressionQuality: 0.7)
        }
        
        return cell
    }
    
    func addAddress() {
        router.routeTo(.addAdress)
    }
    
}

extension AnotherProductController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let cell =  collectionView.dequeueReusableView(CustomEmptyView.self, kind: UICollectionView.elementKindSectionFooter, for: indexPath)
            cell.setup(data: emptyViewData)
            return cell
        default: assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if  products.isEmpty {
            return collectionView.frame.size
        }
        let item = products[indexPath.row].medias?.first
        let heightImage = Double(item?.metadata?.height ?? "") ?? 1028
        let widthImage = Double(item?.metadata?.width ?? "") ?? 1028
        let width = collectionView.frame.size.width - 4
        let scaler = width / widthImage
        let percent = Double((10 - ((indexPath.row % 3) + 1))) / 10
        var height = heightImage * scaler
        if height > 500 {
            height = 500
        }
        height = (height * percent) + 200
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.router.routeTo(.seeProduct(shop: products[indexPath.row].toProduct(), account: self.account))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - 50
        if (offsetY > contentHeight - scrollView.frame.height) {
            if !onLoading && (page + 1) < totalPages {
                page += 1
                if onSearch {
                    loadSearch(mainView.searchBarTextField.text ?? "")
                } else {
                    loadList()
                }
            }
        }
    }
}

extension AnotherProductController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchingText = textField.text ?? ""
        self.clearData()
        if !searchingText.isEmpty{
            self.onSearch = true
            self.loadSearch(searchingText)
            return true
        }
        
        refreshUI()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let searchingText = textField.text ?? ""
        self.mainView.updateSearchView(isEmpty: searchingText.isEmpty)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let searchingText = textField.text ?? ""
        self.clearData()
        if !searchingText.isEmpty{
            self.onSearch = true
            self.loadSearch(searchingText)
            return
        }
        
        refreshUI()
    }
    
}
