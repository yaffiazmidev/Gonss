//
//  ProductArchiveController.swift
//  KipasKipas
//
//  Created by IEN-Yasin-MacbookPro on 22/05/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol ProductArchiveDisplayLogic where Self: UIViewController {
    func displayViewModel(_ viewModel: ProductArchiveModel.ViewModel)
}

class ProductArchiveController: UIViewController, Displayable, AlertDisplayer, ProductArchiveDisplayLogic {
    
    var mainView: ProductArchiveView!
    private var presenter: ProductArchivePresenter!
    private var router: ProductArchiveRouting!
    private var route : ProductArchiveRouter?
    private var interactor: ProductArchiveInteractable!
    private let disposeBag = DisposeBag()
    
    private var reloadCollectionFirst = false
    
    private var productID = ""
    private var product : ProductItem?
    private var image : UIImage?
    private var data : Data?
    
	fileprivate lazy var productActionSheet : ProductActionSheet = {
		let sheet = ProductActionSheet(controller: self, delegate: self, isArchive: true)
		return sheet
	}()
        
    private enum ViewTrait {
        static let emptyBoldText: String = "Tidak ada produk yang diarsipkan"
        static let notFoundBoldText: String = "Produk tidak ditemukan"
        static let notFoundSoftText: String = "tidak dapat ditemukan, masukan kata kunci yang lain"
    }


    required init(mainView: ProductArchiveView, dataSource: ProductArchiveModel.DataSource) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
        interactor = ProductArchiveInteractor(viewController: self, dataSource: dataSource)
        router = ProductArchiveRouter(self)
        presenter = ProductArchivePresenter(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavigationBar(String.get(.archiveProducts))
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: false)
        presenter.requestedPage = 0
        presenter.getNetworkProductArchive()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hideKeyboardWhenTappedAround()
        route = ProductArchiveRouter(self)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    override func loadView() {
        view = mainView
        view.backgroundColor = .white
    }
    
    //MARK: - Product Archive Display Logic
    func displayViewModel(_ viewModel: ProductArchiveModel.ViewModel) {
        switch viewModel {
        case .product(let viewModel):
            displayArchiveProductResult(viewModel)
        case .empty:
            displayEmptyArchiveProduct()
        case .notFound:
            displayNotFound()
        case .delete(let viewModel):
            displayDeleteProduct(viewModel)
        case .pagination(let viewModel):
            displayPaginationArchiveProduct(viewModel)
        }
    }
    
    
    func setup() {
            
            self.mainView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
            self.mainView.collectionView.rx.setDataSource(self).disposed(by: disposeBag)
            self.mainView.delegate = self
            self.mainView.searchBar.rx.controlEvent([.editingChanged])
                .asObservable()
                .withLatestFrom(self.mainView.searchBar.rx.text.orEmpty)
                .subscribe(onNext: { (text) in
                    if text.count == 0 {
                        self.mainView.emptyStateView.isHidden = true
                    }
                    self.presenter.lastPage = 0
                    self.presenter.requestedPage = 0
                    let searchingText = text
                    self.mainView.notFoundLabel.text = "’\(searchingText)’ \(ViewTrait.notFoundSoftText)"
                    self.presenter.searchArchiveProducts(searchingText: searchingText)
                    
                })
                .disposed(by: disposeBag)
            
            
            self.mainView.collectionView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
                
                if indexPath.row == ((self.presenter.requestedPage * 10) - 1) && self.presenter._loadingState.value == false && self.mainView.searchBar.text == "" {
                    self.presenter.getNetworkProductArchive()
                }
            }).disposed(by: disposeBag)
            
            presenter.loadingState.asObservable().subscribe { bool in
                if (!bool) {
                    self.mainView.refreshController.endRefreshing()
                }
            } onError: { error in
                print(error)
            } onCompleted: {
            }.disposed(by: disposeBag)
        
        presenter._errorMessage.bind { [weak self] error in
            guard let error = error else { return }
            self?.displayAlert(with: .get(.error), message: error, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        }.disposed(by: disposeBag)
        }
}

// MARK: - Collection View Delegate
extension ProductArchiveController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let items = self.interactor.dataSource.data
        items?.count == 0 && reloadCollectionFirst ? displayEmptyArchiveProduct(): nil
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        reloadCollectionFirst = true
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCustomCell(with: ProductItemCell.self, indexPath: indexPath)
        if let items = self.interactor.dataSource.data {
            cell.configure(items[row])
            cell.onMoreClick = {
                self.product = ProductItem.fromProduct(items[row])
                self.productActionSheet.showSheet(self.product!, index: row)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let items = self.interactor.dataSource.data {
            routeToDetail(product: items[indexPath.row])
        }
    }
    
    func routeToDetail(product: Product){
        let detailController = ProductDetailFactory.createProductDetailController(dataSource: product)
        detailController.deleteCallback = {
            self.presenter.getNetworkProductArchive()
            self.route?.toDeleteSuccessView()
        }
        detailController.hidesBottomBarWhenPushed = true
        detailController.isArchive = true
        navigationController?.pushViewController(detailController, animated: true)
    }
}



// MARK: - Private Zone
private extension ProductArchiveController {
    
    func displayArchiveProductResult(_ viewModel: [Product]) {
        mainView.searchBar.isHidden = false
        mainView.collectionView.isHidden = false
        mainView.emptyStateView.isHidden = true
        
        self.interactor.dataSource.data = viewModel
        mainView.collectionView.reloadData()
    }
    
    func displayPaginationArchiveProduct(_ viewModel: [Product]) {
            self.interactor.dataSource.data?.append(contentsOf: viewModel)
            mainView.collectionView.reloadData()
    }
    
    func displayEmptyArchiveProduct() {
        
        mainView.searchBar.isHidden = true
        mainView.collectionView.isHidden = true
        mainView.emptyStateView.isHidden = false
        mainView.notFoundLabel.isHidden = true
        
        mainView.image.image = UIImage(named: String.get(.iconEmptyBold))
        mainView.label.text = ViewTrait.emptyBoldText
        
    }
    
    func displayNotFound() {
        
        mainView.searchBar.isHidden = false
        mainView.collectionView.isHidden = true
        mainView.emptyStateView.isHidden = false
        mainView.notFoundLabel.isHidden = false
        
        mainView.image.image = UIImage(named: String.get(.iconNotFoundBold))
        mainView.label.text = ViewTrait.notFoundBoldText
        
    }
    
    func displayDeleteProduct(_ id: String) {
        self.interactor.dataSource.data = self.interactor.dataSource.data?.filter { !($0.id?.contains(id) ?? false) }
        mainView.collectionView.reloadData()
    }
    
}



extension ProductArchiveController : ProductArchiveViewDelegate {
    func refreshUI() {
        presenter.lastPage = 0
        presenter.requestedPage = 0
        presenter.getNetworkProductArchive()
    }
}

extension ProductArchiveController : ProductActionSheetDelegate {
	func activeSuccess() {
		self.refreshUI()
        NotificationCenter.default.post(name: .callbackWhenActiveProduct, object: nil)
	}
	
	func activeError(errorMsg: String) {
		self.presenter._errorMessage.accept(errorMsg)
	}
	
	
	func archiveSuccess() {
		let route = ProductRouter(self)
		route.toArchive()
	}
	
	func archiveError(errorMsg: String) {
		self.presenter._errorMessage.accept(errorMsg)
	}
	
    func deleteSuccess(_ index: Int) {
        DispatchQueue.main.async {
            self.interactor.dataSource.data?.remove(at: index)
            self.mainView.collectionView.reloadData()
            Toast.share.show(message: .get(.successDeleteProduct))
        }
	}
	
	func deleteError(errorMsg: String) {
		self.presenter._errorMessage.accept(errorMsg)
	}
	
}
