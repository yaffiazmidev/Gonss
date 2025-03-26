//
//  NotificationController.swift
//  KipasKipas
//
//  Created by movan on 13/08/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class NotificationController: UIViewController {
	
	private let menuArray = [StringEnum.social.rawValue, StringEnum.transaksi.rawValue]
	private var presenterTransaction = NotificationTransactionPresenter(router: nil)
	private var router: NotificationSocialRouter!
	private var presenterSocial : NotificationSocialPresenter!
	private var disposeBag = DisposeBag()
    private var presenter: NotificationPresenter!
	
	private var sizeArray : [BehaviorRelay<String>]?
	var controllerIndex = 0
	
	lazy var viewControllerList: [UIViewController] = [
		NotificationSocialController(mainView: NotificationSocialView()),
		NotificationTransactionController(mainView: NotificationTransactionView())
	]
	
	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.isScrollEnabled = false
		view.backgroundColor = .white
		view.delegate = self
		view.dataSource = self
		view.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
		view.registerCustomCell(ProfileFilterCell.self)
		return view
	}()
	
	let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    required init(presenter: NotificationPresenter) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
        presenter.notificationSocialResponse(page: 0, size: 20)
        presenter.notificationTransactionResponse(page: 0, size: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
		
		router = NotificationSocialRouter(self)
		presenterSocial = NotificationSocialPresenter(router: router)
		
       
		layoutPageView()
		view.backgroundColor = .white
		let pageView = pageViewController.view!
		
		[collectionView, pageView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 50)
		pageView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
		
		sizeArray = [presenterSocial.notificationSize, presenterTransaction.notificationSize]
		createObserver()
		setBarItem()
	}

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		tabBarController?.tabBar.isHidden = false
		navigationController?.hideKeyboardWhenTappedAround()
		navigationController?.displayShadowToNavBar(status: false)
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		navigationController?.navigationBar.backgroundColor = nil
	}
	
	fileprivate func layoutPageView() {
		pageViewController.delegate = self
		pageViewController.dataSource = self
		//		pageViewController.automaticallyAdjustsScrollViewInsets = false
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.setViewControllers([viewControllerList[0]], direction: .forward, animated: true)
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
	}
	
	func setBarItem(){
		self.navigationController?.navigationBar.tintColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//		self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//			image: UIImage(named: String.get(.iconButtonShopBrand))?.withRenderingMode(.alwaysOriginal),
//			style: .plain, target: self, action: #selector(handleShowShop))
		
		
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			image: UIImage(named: String.get(.Kipaskipas))?.withRenderingMode(.alwaysOriginal),
			style: .plain, target: self, action: nil)
		self.navigationItem.leftBarButtonItem?.isEnabled = false
	}
	
	
	@objc func handleShowShop() {
		self.presenterSocial.routeToShowProducts()
	}
    
    func routeToPenjualan(){
        let controller = StatusTransactionController()
        controller.backToPenjualan()
        self.navigationController?.pushViewController(controller, animated: true)
    }
}


// MARK: - NotificationViewDelegate
extension NotificationController: UIGestureRecognizerDelegate,
																	UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIPageViewControllerDelegate,
																	UIPageViewControllerDataSource  {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 2
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: ProfileFilterCell.self, indexPath: indexPath)
		cell.titleLabel.text = menuArray[indexPath.row]
        cell.backgroundColor = .white
		sizeArray![indexPath.row].asObservable().bind(to: cell.counterLabel.rx.title(for: .normal)).disposed(by: disposeBag)
        if sizeArray![indexPath.row].value == "0"{
            cell.counterLabel.isHidden = true
        }
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = view.frame.width  / 2 - 10
		return CGSize(width: width, height: 50)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		pageViewController.setViewControllers([viewControllerList[indexPath.item]], direction: .forward, animated: false, completion: nil)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
		let previousIndex = vcIndex - 1
		guard previousIndex >= 0 else { return nil }
		guard viewControllerList.count > previousIndex else { return nil }
		return viewControllerList[previousIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let vcIndex = viewControllerList.firstIndex(of: viewController) else { return nil }
		let nextIndex = vcIndex + 1
		guard viewControllerList.count != nextIndex else { return nil }
		guard viewControllerList.count > nextIndex else { return nil }
		return viewControllerList[nextIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed {
			if let currentViewController = pageViewController.viewControllers?.first,
				 let index = viewControllerList.firstIndex(of: currentViewController) {
				collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
				controllerIndex = index
			}
		}
	}
	
	func createObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounter), name: .notifyCounterTransaction, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounter), name: .notifyCounterSocial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounterSocial(notif:)), name: .notifyUpdateCounterSocial, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCounterTransaction(notif:)), name: .notifyUpdateCounterTransaction, object: nil)
	}
	
	@objc
	func updateCounter(){
		presenterSocial.page = 0
		presenterTransaction.page = 0
		presenterSocial.fetchNotificationResult()
		presenterTransaction.fetchNotificationResult()
	}
	
    @objc func updateCounterSocial(notif: NSNotification) {
        guard let data = (notif.object as? [String: Any])?.first?.value as? Tampung else {
            return 
        }
        presenterSocial.page = data.page ?? 0
        presenterSocial.notificationSize.accept(String( data.size ?? 0 ))
    }
    
    @objc func updateCounterTransaction(notif: NSNotification) {
        guard let data = (notif.object as? [String: Any])?.first?.value as? Tampung else {
            return
        }
        presenterTransaction.page = data.page ?? 0
        presenterTransaction.notificationSize.accept(String( data.size ?? 0 ))
    }
}

struct Tampung: Hashable {
    var page: Int?
    var size: Int?
}

