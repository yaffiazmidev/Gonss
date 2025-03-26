//
//  AddProductResellerController.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking

class ResellerProductSelectController: UIViewController, UIGestureRecognizerDelegate {
    private let mainView: ResellerProductSelectView
    private var headerCell: ResellerProductSelectHeaderCell?
    
    var loader: RemoteResellerDataLoader!
    private var products: [ProductItem] = []
    private var page: Int = 0
    private var totalPages: Int = 0
    private var onLoading: Bool = false
    
    var onSuccessAddProduct: (() -> Void)?
    
    required init(){
        mainView = ResellerProductSelectView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    override func loadView() {
        super.loadView()
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.collectionView.delegate = self
        mainView.collectionView.dataSource = self
        mainView.refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        setupNavBar()
        refresh()
    }
}

extension ResellerProductSelectController {
    func setupNavBar() {
        title = .get(.choiceProduct)
        navigationController?.hideKeyboardWhenTappedAround()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: .get(.arrowleft)),
                                                           style: .plain, target: self, action: #selector(back))
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    
    @objc private func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func scrollToSearch(){
        let toolbarHeight = (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0) +
        (self.navigationController?.navigationBar.frame.height ?? 44)
        UIView.animate(withDuration: 0.2, animations: {
            self.mainView.collectionView.setContentOffset(CGPoint(x: 0, y: -toolbarHeight), animated: false)
        }, completion: { _ in
            self.headerCell?.textField.becomeFirstResponder()
        })
    }
    
    @objc private func refresh() {
        clearData()
        loadList()
    }
    
    private func clearData(){
        self.page = 0
        self.totalPages = 0
        self.products = []
        self.mainView.collectionView.reloadData()
    }
}

//MARK: - Loader Implementataion
extension ResellerProductSelectController {
    private func loadList(){
        let request = ResellerDataLoaderRequest(keyword: headerCell?.textField.text ?? "", page: page)
        self.onLoading = true
        print("9490 - load data \(page) of \(totalPages) with \(headerCell?.textField.text ?? "")")
        loader.load(request: request) { [weak self] result in
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
                    //                    self.showErrorView(self.getErrorMessage(error))
                    self.mainView.refreshController.endRefreshing()
                    self.mainView.collectionView.reloadData()
                }
            }
        }
    }
    
    private func updateProducts(_ result: ProductArrayItem){
        self.page == 0 ? self.products = result.data : self.products.append(contentsOf: result.data)
        self.totalPages = result.totalPages
        self.mainView.refreshController.endRefreshing()
        self.mainView.collectionView.reloadData()
    }
    
    private func showErrorView(title: String = "",message: String){
        let emptyView = CustomEmptyView()
        emptyView.setup(title: title, message: message)
        emptyView.iconImage.isHidden = false
        mainView.collectionView.backgroundView = emptyView
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


extension ResellerProductSelectController: ResellerProductSelectHeaderCellDelegate{
    func didSearch(_ text: String) {
        refresh()
    }
    
    func didChanged(_ text: String) {
        
    }
    
    func didClear() {
        refresh()
    }
}

extension ResellerProductSelectController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ResellerProductSelectItemCell.self, for: indexPath)
        cell.setupView(products[indexPath.row])
        return cell
    }
}

extension ResellerProductSelectController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let product: ProductItem = products[indexPath.row]
        let params: ConfirmProductParams = ConfirmProductParams(id: product.id, accountId: product.accountId, productName: product.name, price: product.price, commission: product.commission, imageURL: product.medias?.first?.thumbnail?.medium ?? "")
        let controller = ResellerConfirmProductUIFactory.create(with: params) { [weak self] in
            guard let self = self else { return }
            self.refresh()
        }
        
        controller.bindNavigationBar("Pilih Product", true)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let cell = collectionView.dequeueReusableView(ResellerProductSelectHeaderCell.self, kind: UICollectionView.elementKindSectionHeader, for: indexPath)
            cell.delegate = self
            headerCell = cell
            return cell
        default: assert(false, "Unexpected element kind")
        }
    }
}

extension ResellerProductSelectController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(all: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 24, height: 64)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.isDragging else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - 50
        if (offsetY > contentHeight - scrollView.frame.height) {
            if !onLoading && (page + 1) < totalPages {
                page += 1
                loadList()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}
