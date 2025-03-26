//
//  MyProductViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 12/01/22.
//

import UIKit
import RxSwift
import KipasKipasNetworking

class MyProductViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var searchBarStackView: UIStackView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomLoadingStackView: UIStackView!
    private var emptyView: CustomEmptyView?

    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(refreshUI), for: .valueChanged)
        return refresh
    }()
    
    var listLoader: RemoteProductListLoader!
    var searchLoader: RemoteProductSearchLoader!
    var balanceLoader: RemoteMyStoreBalanceLoader!
    var addressLoader: RemoteMyStoreAddressLoader!
    var router: MyProductRouterRoutingLogic!
    var isVerified: Bool!
    
    fileprivate var productActionSheet: ProductActionSheet? = ProductActionSheet()
    fileprivate var productActionAddSheet: ProductActionAddSheet? = ProductActionAddSheet()
    private let disposeBag = DisposeBag()
    private var product: ProductItem?
    private var balance: MyStoreBalance?
    private var flowLayout: DENCollectionViewLayout!
    private var isEmailEmpty = getEmail() == ""
    private var isAddressEmpty = false
    private var products: [ProductItem] = []
    var indexProduct = 0
    private var type: ProductType = .all
    private var page: Int = 0
    private var totalPages: Int = 0
    private var onSearch: Bool = false
    private var onLoading: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewDidload()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.backgroundColor = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleViewDidload() {
        setupNavBar()
        setupCollectionView()
        
        refreshUI()
        
        searchBar.rx.controlEvent(.editingChanged)
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .debounce(.milliseconds(1500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.clearData()
                self.onSearch = true
                !text.isEmpty ? self.loadSearch(text) : self.refreshUI()
            }).disposed(by: disposeBag)
        
        productActionSheet = ProductActionSheet(controller: self, delegate: self, isVerified: self.isVerified)
        productActionAddSheet = ProductActionAddSheet(controller: self, delegate: self)
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        
        collectionView.register(UINib(nibName: "MyProductHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyProductHeaderCollectionReusableView")
        collectionView.registerXibCell(ProductViewCell.self)
        collectionView.registerReusableView(CustomEmptyView.self, kind: UICollectionView.elementKindSectionFooter)
        setupPinterestLayout()
    }
    
    private func setupPinterestLayout() {
        flowLayout = DENCollectionViewLayout()
        flowLayout.columnCount = 2
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumColumnSpacing = 0
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.collectionViewLayout = flowLayout
        updateFlowLayoutHeight()
    }
    
    private func updateFlowLayoutHeight(){
        flowLayout.headerHeight = 247 + (isEmailEmpty ? 106 : 0) + (isAddressEmpty ? 106 : 0) + (42 + 38)
        flowLayout.footerHeight = products.isEmpty ? collectionView.frame.height - flowLayout.headerHeight : 0
    }
    
    
    func setupNavBar() {
        title = .get(.shopping)
        navigationController?.hideKeyboardWhenTappedAround()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: String.get(.iconEllipsis)),
                                                            style: .plain, target: self, action: #selector(onClickEllipse))
        searchBar.attributedPlaceholder = NSAttributedString(string: "Cari produk...",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder,
                                                                          NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12)])
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc func onClickEllipse() { router.showMyStoreSetting() }
    
    @objc private func back() {
        router.dismiss()
    }
    
    @objc func refreshUI() {
        searchBar.text = nil
        onSearch = false
        clearData()
        loadBalance()
        loadList()
        loadAddress()
    }
    
    @IBAction func didClickAddProduct(_ sender: Any) {
        self.productActionAddSheet?.showSheet()
    }
    
    func updateRow(at index: Int, data: ProductItem) {
        collectionView.performBatchUpdates {
            products.remove(at: index)
            products.insert(data, at: index)
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } completion: { status in
            print("update row  at \(index) is \(status)")
        }
    }
    
    private func clearData(){
        self.page = 0
        self.totalPages = 0
        self.products = []
        self.collectionView.reloadData()
    }
}

//MARK: - Loader Implementataion
extension MyProductViewController {
    private func loadList(){
        let request = ProductListLoaderRequest(accountId: getIdUser(), page: page, type: type.rawValue)
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
                    self.emptyView?.setup(title: "Gagal memuat data", message: self.getErrorMessage(error))
                    self.updateFlowLayoutHeight()
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadSearch(_ text: String){
        let request = ProductSearchLoaderRequest(accountId: getIdUser(), page: page, type: type.rawValue, keyword: text)
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
                    let message = "\"\(self.searchBar.text ?? "")\" " + .get(.notFoundNameProduct) + "\nError: \(self.getErrorMessage(error))"
                    Toast.share.show(message: message)
                    self.emptyView?.setup(title: "Gagal memuat data", message: message)
                    self.updateFlowLayoutHeight()
                    self.refreshControl.endRefreshing()
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func loadAddress(){
        let request = MyStoreAddressLoaderRequest(type: "SELLER_ADDRESS")
        addressLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                DispatchQueue.main.async {
                    self.isAddressEmpty = item.isEmpty
                    self.updateFlowLayoutHeight()
                    self.collectionView.reloadData()
                    self.searchBarStackView.isHidden = self.isEmailEmpty
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    Toast.share.show(message: self.getErrorMessage(error))
                    self.isAddressEmpty = true
                    self.updateFlowLayoutHeight()
                    self.collectionView.reloadData()
                    self.searchBarStackView.isHidden = true
                }
            }
        }
    }
    
    private func loadBalance(){
        balanceLoader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(item):
                DispatchQueue.main.async {
                    self.balance = item
                    self.collectionView.reloadData()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    Toast.share.show(message: self.getErrorMessage(error))
                }
            }
        }
    }
    
    private func updateProducts(_ result: ProductArrayItem){
        if result.data.isEmpty {
            if onSearch {
                let message = "\"\(self.searchBar.text ?? "")\" " + .get(.notFoundNameProduct)
                Toast.share.show(message: message)
                emptyView?.setup(icon: .get(.iconNotFoundBold),title: "Produk tidak ditemukan", message: message)
            } else {
                emptyView?.setup(icon: .get(.iconEmptyBold), title: "Anda belum menambahkan produk apapun")
            }
        }
        self.page == 0 ? self.products = result.data : self.products.append(contentsOf: result.data)
        self.totalPages = result.totalPages
        if !onSearch {
            self.bottomLoadingStackView.isHidden = true
        }
        self.updateFlowLayoutHeight()
        self.refreshControl.endRefreshing()
        self.collectionView.reloadData()
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

extension MyProductViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ProductViewCell.self, for: indexPath)
        cell.setupView(products[indexPath.item], isSelf: true)
        cell.optionMore.onTap { [weak self] in
            guard let self = self else { return }
            self.product = self.products[indexPath.item]
            self.productActionSheet?.showSheet(self.products[indexPath.item])
            self.indexProduct = indexPath.item
        }
        cell.updateStockButton.onTap {[weak self] in
            guard let self = self else { return }
            
            self.router.editProduct(self.products[indexPath.item].toProduct())
        }
        return cell
    }
}

extension MyProductViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        router.seeProduct(products[indexPath.item].toProduct()) { [weak self] in
            guard self != nil else { return }
            self?.refreshUI()
        }
        
        indexProduct = indexPath.item
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isDragging else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - 50
        if (offsetY > contentHeight - scrollView.frame.height) {
            if !onLoading && (page + 1) < totalPages {
                page += 1
                if onSearch {
                    loadSearch(searchBar.text ?? "")
                } else {
                    loadList()
                    bottomLoadingStackView.isHidden = false
                }
            }
        }
    }
}

extension MyProductViewController: ProductActionSheetDelegate {
    func activeSuccess() {}
    func activeError(errorMsg: String) { }
    func deleteSuccess(_ index: Int) {}
    func deleteError(errorMsg: String) {}
    
    func archiveSuccess() {
        refreshUI()
        Toast.share.show(message: "Product berhasil di arsipkan") { [weak self] in
            guard let self = self else { return }
            let route = ProductRouter(self)
            route.toArchive()
            NotificationCenter.default.addObserver(self, selector: #selector(self.handleCallbackFromArchive), name: .callbackWhenActiveProduct, object: nil)
        }
    }
    
    func archiveError(errorMsg: String) {
        Toast.share.show(message: errorMsg)
    }
    
    @objc func handleCallbackFromArchive() { refreshUI() }
    
    func resellerUpdated() { refreshUI() }
}

extension MyProductViewController: DENCollectionViewDelegateLayout {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "MyProductHeaderCollectionReusableView", for: indexPath) as! MyProductHeaderCollectionReusableView
            cell.delegate = self
            cell.emailSection = isEmailEmpty ? 1 : 0
            cell.addressSection = isAddressEmpty ? 1 : 0
            cell.balance = balance
            cell.productType = type
            return cell
        case UICollectionView.elementKindSectionFooter:
            let cell =  collectionView.dequeueReusableView(CustomEmptyView.self, kind: UICollectionView.elementKindSectionFooter, for: indexPath)
            self.emptyView = cell
            return cell
        default: assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if products.indices.contains(indexPath.row) {
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
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(horizontal: 12, vertical: 0)
    }
}

extension MyProductViewController: MyProductHeaderDelegate{
    func didViewTransactionHistory() {
        self.router.showHistoryWithdrawal()
    }
    
    func didWithdrawBalance() {
        self.router.navigateToWithdrawBalance { [weak self] in
            self?.refreshUI()            
        }
    }
    
    func didMessageAddress() {
        self.router.addAddress()
    }
    
    func didMessageEmail() {
        self.router.navigateToProfileSetting()
    }
    
    func didSelectProductType(_ type: ProductType) {
        self.type = type
        clearData()
        if onSearch {
            loadSearch(searchBar.text ?? "")
        }else {
            loadList()
        }
    }
}

extension MyProductViewController: ProductActionAddSheetDelegate {
    func didCreateNewProduct() {
        router.createNewProduct(product: Product()) { [weak self] in self?.refreshUI() }
    }
    
    func didAddResellerProduct() {
        router.addResellerProduct { [weak self] in self?.refreshUI() }
    }
}
