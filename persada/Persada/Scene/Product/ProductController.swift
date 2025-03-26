//
//  ProductController.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.


import UIKit
import RxCocoa
import RxSwift
import KipasKipasShared

protocol ProductDisplayLogic where Self: UIViewController {
	
	func displayViewModel(_ viewModel: ProductModel.ViewModel)
}

class ProductController: UIViewController, Displayable, ProductDisplayLogic, AlertDisplayer {
	
	var mainView: ProductView
    var interactor: ProductInteractable!
	var presenter: ProductPresenter!
	private var router: ProductRouting!
	private var isSeller = false
	private let disposeBag = DisposeBag()
	
	private let hud = CPKProgressHUD.progressHUD(style: .loading(text: nil))
	
    
    private var productID = ""
    private var product : Product?
    private var image : UIImage?
    private var data : Data?
    
	fileprivate lazy var productActionSheet : ProductActionSheet = {
        let sheet = ProductActionSheet(controller: self, delegate: self)
		return sheet
	}()
	
	private enum Section: String,CaseIterable {
		case productShop = "product"
	}
	
	required init(mainView: ProductView, dataSource: ProductModel.DataSource) {
		self.mainView = mainView
		super.init(nibName: nil, bundle: nil)
		presenter = ProductPresenter(self)
		interactor = ProductInteractor(viewController: self, dataSource: dataSource)
		router = ProductRouter(self)
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		bindNavigationBar(String.get(.shopping))
		let rightBarButton = UIBarButtonItem(image: UIImage(named: String.get(.iconEllipsis))?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(onClickEllipse(_:)))
		self.navigationItem.rightBarButtonItem = rightBarButton
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.navigationBar.backgroundColor = .white
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		tabBarController?.tabBar.isHidden = false
		navigationController?.setNavigationBarHidden(false, animated: false)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
//        if let text = mainView.searchBar.text { presenter.searchProducts(searchingText: text) } else { refreshUI() }
        refreshUI()
		setup()
		navigationController?.hideKeyboardWhenTappedAround()
		self.interactor.setPage(data: 0)
	}
	
	@objc func onClickEllipse(_ sender: UIBarButtonItem)
	{
		let option1 = SortByOptionItem(text: .AddProduct, isSelected: false)
		presentOptionsPopover(withOptionItems: [[option1]], fromBarButtonItem: sender)
	}
	
	override func loadView() {
		view = mainView
		mainView.searchBar.delegate = self
		mainView.delegate = self
		view.backgroundColor = .white
	}
	
	func setup() {
		
		self.mainView.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
		self.mainView.collectionView.rx.setDataSource(self).disposed(by: disposeBag)
		
		self.mainView.collectionView.rx.willDisplayCell.subscribe(onNext: { cell, indexPath in
			if let items = self.interactor.dataSource.data {
				if indexPath.row == items.count - 1 && self.presenter._loadingState.value == false && self.mainView.searchBar.text == "" {
					self.presenter.getNetworkProduct()
				}
			}
		}).disposed(by: disposeBag)
		
		//presenter.products.asObservable().bind { product in
		//let resultSearching = product.count == 0 && self.mainView.searchBar.text != ""
		//self.mainView.collectionView.isHidden = resultSearching
		//self.mainView.emptyStateView.isHidden = !resultSearching
		//self.mainView.collectionView.reloadData()
		//}.disposed(by: disposeBag)
		
		presenter.loadingState.asObservable().subscribe { bool in
			if (!bool) {
				self.mainView.refreshController.endRefreshing()
			}
		} onError: { error in
			print(error)
		} onCompleted: {
		}.disposed(by: disposeBag)
        
        mainView.searchBar.rx
            .controlEvent(.editingChanged)
            .withLatestFrom(mainView.searchBar.rx.text.orEmpty)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                self.presenter.lastPage = 0
                self.presenter.requestedPage = 0
                !text.isEmpty ? self.presenter.searchProducts(searchingText: text) : self.refreshUI()
            }).disposed(by: disposeBag)
    }
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
	}

	// MARK: - ProductDisplayLogic
	func displayViewModel(_ viewModel: ProductModel.ViewModel) {
		DispatchQueue.global(qos: .background).async {
			switch viewModel {
			
			case .product(let viewModel):
				self.displayShopResult(viewModel)
			case .paginationProduct(let viewModel):
				self.displayPaginationShop(viewModel)
			case .listProductById(viewModel: let viewModel):
				self.displayPaginationShop(viewModel)
			case .presentErrorResponse(data: let data):
				let title = "ERROR"
				let action = UIAlertAction(title: "OK", style: .default)
				self.displayAlert(with: title , message: data.statusMessage ?? "", actions: [action])
			case .emptySearchProduct:
				self.displayEmptySearch()
			case .checkTheAddress(_): break
//				self.showAddress(viewModel)
            default:
                break
			}
		}
	}
    
    func updateRow(at index: Int, data: Product) {
        mainView.collectionView.performBatchUpdates {
            interactor.dataSource.data?.remove(at: index)
            interactor.dataSource.data?.insert(data, at: index)
            mainView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } completion: { status in
            print("update row  at \(index) is \(status)")
        }
    }
}


// MARK: - ProductViewDelegate
extension ProductController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,UIGestureRecognizerDelegate {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Section.allCases.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let items = self.interactor.dataSource.data
		return items?.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let row = indexPath.item
		
		let cell = collectionView.dequeueReusableCustomCell(with: ProductItemCell.self, indexPath: indexPath)
		if let items = self.interactor.dataSource.data {
			cell.configure(items[row])
            cell.onMoreClick = {
                self.product = items[row]
                self.presenter.indexProduct = row
                self.productActionSheet.showSheet(ProductItem.fromProduct(items[row]), index: row)
            }
		}
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let sectionType = Section.allCases[indexPath.section]
		switch sectionType {
		case .productShop:
			if let items = self.interactor.dataSource.data {
				let row = indexPath.item
                self.presenter.indexProduct = row
				self.router.routeTo(.seeProduct(shop: items[row]))
			}
		}
	}
    
}

extension ProductController : ProductViewDelegate {
	func addAddress() {
		router.routeTo(.addAdress)
	}
	
	@objc func refreshUI() {
        mainView.searchBar.text = nil
		presenter.lastPage = 0
		presenter.requestedPage = 0
		presenter.getNetworkProduct()
		presenter.requestCheckAddress()
	}
	
	func showQRReader() {
		router.routeTo(.showQR)
	}
	
}


// MARK: - Private Zone
private extension ProductController {
	
	func displayShopResult(_ viewModel: [Product]) {
		self.interactor.dataSource.data = viewModel
		
		DispatchQueue.main.async {
            self.mainView.collectionView.isHidden = false
            self.mainView.emptyStateView.isHidden = true
			self.mainView.collectionView.reloadData()
		}
	}
	
	func displayPaginationShop(_ viewModel: [Product]) {
		
		self.interactor.dataSource.data?.append(contentsOf: viewModel)
		DispatchQueue.main.async {
			self.mainView.collectionView.reloadData()
		}
		

	}
	
	func presentOptionsPopover(withOptionItems items: [[RBOptionItem]], fromBarButtonItem barButtonItem: UIBarButtonItem) {
		let optionItemListVC = RBOptionItemListViewController()
		optionItemListVC.delegate = self
		optionItemListVC.items = items
		
		guard let popoverPresentationController = optionItemListVC.popoverPresentationController else { fatalError("Set Modal presentation style") }
		popoverPresentationController.barButtonItem = barButtonItem
		popoverPresentationController.delegate = self
		self.present(optionItemListVC, animated: true, completion: nil)
	}
	
	func displayEmptySearch() {
		
		DispatchQueue.main.async {
			self.mainView.collectionView.isHidden = true
            self.mainView.emptyStateLabel.text = "’\(String(describing: self.mainView.searchBar.text))’ tidak dapat ditemukan, masukan kata kunci yang lain."
			self.mainView.emptyStateView.isHidden = false
		}
	}
	
	func showAddress(_ viewModel: [Address]) {
		self.mainView.updateView(isNotHaveAddress: viewModel.isEmpty)
	}
}

extension ProductController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
}

extension ProductController : RBOptionItemListViewControllerDelegate {
	func optionItemListViewController(_ controller: RBOptionItemListViewController, didSelectOptionItem item: RBOptionItem) {
		if item.text == .AddProduct {
			router.routeTo(.addProduct)
		}
	}
}

extension ProductController: UITextFieldDelegate { }


extension ProductController : ProductActionSheetDelegate {
	
	func activeSuccess() {
		
	}
	
	func activeError(errorMsg: String) {

	}
	
	func archiveSuccess() {
        DispatchQueue.main.async {
            let items = self.interactor.dataSource.data?.filter({ $0.id != self.product?.id ?? "" })
            self.interactor.dataSource.data = items
            self.mainView.collectionView.reloadData()
            let route = ProductRouter(self)
            route.toArchive()
        }
	}
	
	func archiveError(errorMsg: String) {
		self.presenter._errorMessage.accept(errorMsg)
	}
	
    func deleteSuccess(_ index: Int) {
		
	}
	
	func deleteError(errorMsg: String) {
		self.presenter._errorMessage.accept(errorMsg)
	}
	
}
