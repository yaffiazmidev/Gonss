//
//  StatusTransactionController.swift
//  KipasKipas
//
//  Created by NOOR on 18/01/21.
//  Copyright (c) 2021 Koanba. All rights reserved.
//

import UIKit

final class StatusTransactionController: UIViewController {

	private let menuArray = ["Pembelian", "Penjualan"]
	
	lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.isScrollEnabled = false
		view.backgroundColor = .white
		view.delegate = self
		view.dataSource = self
		view.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .left)
		view.registerCustomCell(StatusTransactionTabCell.self)
		return view
	}()

	let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	
	lazy var viewControllerList: [UIViewController] = [
		OrderPurchaseController(),
		OrderSalesController(),
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		layoutPageView()
		view.backgroundColor = .white
		let pageView = pageViewController.view!
		
		[collectionView, pageView].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}
		
		collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 50)
		pageView.anchor(top: collectionView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 16)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		bindNavigationBar(String.get(.detailTransaction))
//		tabBarController?.tabBar.isHidden = true
		navigationController?.hideKeyboardWhenTappedAround()
//		navigationController?.displayShadowToNavBar(status: true)
		navigationController?.navigationBar.backgroundColor = UIColor.white
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
		navigationItem.title = String.get(.statusTransaction)
		navigationController?.interactivePopGestureRecognizer?.delegate = self
		navigationController?.setNavigationBarHidden(false, animated: animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		navigationController?.navigationBar.backgroundColor = nil
	}
	
	fileprivate func layoutPageView() {
		pageViewController.delegate = self
		pageViewController.dataSource = self
		pageViewController.automaticallyAdjustsScrollViewInsets = false
		pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
		pageViewController.setViewControllers([viewControllerList[0]], direction: .forward, animated: true)
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
	}

    func backToPenjualan() {
        pageViewController.setViewControllers([viewControllerList[1]], direction: .forward, animated: true)
        collectionView.selectItem(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
    }
}


// MARK: - StatusTransactionViewDelegate
extension StatusTransactionController: UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIPageViewControllerDelegate, UIPageViewControllerDataSource  {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return viewControllerList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: StatusTransactionTabCell.self, indexPath: indexPath)
		cell.titleLabel.text = menuArray[indexPath.row]
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
			}
		}
	}
}
