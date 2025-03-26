//
//  ChannelSearchController.swift
//  Persada
//
//  Created by Muhammad Noor on 16/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

private let cellId: String = "cellId"

class ChannelSearchController: UIViewController {
	
	// MARK: - Public Property
	
	var viewModel: ChannelSearchViewModel?
	
	lazy var containerView: UIView = {
		let layout = UIView()
		layout.backgroundColor = .white
		layout.translatesAutoresizingMaskIntoConstraints = false
		return layout
	}()
    
    lazy var iconClose: UIView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        image.contentMode = .scaleAspectFit
        image.image = UIImage(named: .get(.iconClose))
        image.onTap { [weak self] in
            ChannelSearchAccountSimpleCache.instance.saveAccounts(accounts: [])
            ChannelSearchHashtagSimpleCache.instance.saveHastags(hashtag: [])
            ChannelSearchTopSimpleCache.instance.saveFeeds(feed: [])
            ChannelSearchTopSimpleCache.instance.saveAccounts(account: [])
            self?.removeText()
        }
        return image
    }()
    
    lazy var searchBar: UITextField = {
        var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
        textfield.clipsToBounds = true
        textfield.placeholder = .get(.cariSiapa)
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
        textfield.layer.cornerRadius = 8
        textfield.textColor = .grey
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
        ]
        textfield.backgroundColor = UIColor.white
        
        textfield.attributedPlaceholder = NSAttributedString(string: .get(.cariSiapa), attributes: attributes)
        textfield.rightViewMode = .always
        
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        textfield.leftViewMode = .always
        textfield.returnKeyType = .done
        textfield.font = .Roboto(.medium, size: 12)
        textfield.textColor = .contentGrey
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.view.frame.height))
        
        containerView.addSubview(iconClose)
        iconClose.center = containerView.center
        textfield.rightView = containerView
        
        return textfield
    }()
    
    lazy var cancelButton: PrimaryButton = {
        let button = PrimaryButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setup(color: .white, textColor: .contentGrey, font: .Roboto(.bold, size: 14))
                button.addTarget(self, action: #selector(self.tappedCancel), for: .touchUpInside)
        return button
    }()
    
    let collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        return collectionView
    }()
    
    lazy var topController: ChannelSearchTopController = {
        let controller = ChannelSearchTopController(mainView: ChannelSearchTopView(), dataSource: ChannelSearchTopModel.DataSource())
        controller.onMoreTapped = { [weak self] in
            guard let self = self else { return }
            self.pageViewController.setViewControllers([self.viewControllerList[1]], direction: .forward, animated: true)
            self.collectionView.selectItem(at: IndexPath(item: 1, section: 0), animated: true, scrollPosition: .left)
            self.triggerSearch()
        }
        return controller
    }()
    
    private let disposeBag = DisposeBag()
	
	var timer = Timer()
	var searchText: String = ""
	var temp = 0
	let menuArray = ["Top", "Account", "Hashtag"]
	var heightProfileUser: CGFloat? = 280
	
	let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	var viewControllerList: [UIViewController]!
    
    let searchContainer = UIView()
	
	// MARK: - Private Method
	
	private func setupSearchBar() {
        searchBar.becomeFirstResponder()
        searchContainer.addSubview(searchBar)
        searchBar.anchor(top: searchContainer.topAnchor, left: searchContainer.leftAnchor, bottom: searchContainer.bottomAnchor, right: searchContainer.rightAnchor, height: 40)
        
        searchContainer.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        searchContainer.fillSuperview(padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchContainer)
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        
	}
    
    private func bindCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.registerCustomCell(ChannelSearchItemCell.self)
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 50)
        collectionView.selectItem(at: IndexPath(item: temp, section: 0), animated: true, scrollPosition: .left)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
    
    private func bindPageController() {
        viewControllerList = {
            let accountController = ChannelSearchAccountController(mainView: ChannelSearchAccountView(), dataSource: ChannelSearchAccountModel.DataSource())
            let hashtagController = ChannelSearchHashtagController(mainView: ChannelSearchHashtagView(), dataSource: ChannelSearchHashtagModel.DataSource())
            return [topController, accountController, hashtagController]
        }()
        
        view.addSubview(containerView)
        containerView.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 0))
        
        // Setup: UIPageViewController
//        pageViewController.automaticallyAdjustsScrollViewInsets = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.setViewControllers([viewControllerList[temp]], direction: .forward, animated: true)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        pageViewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        pageViewController.view.isHidden = true
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.hidesBackButton = true
        
    }
    
    private func bindSearchBar() {
        
        searchBar.rx
            .controlEvent(.editingChanged)
            .withLatestFrom(searchBar.rx.text.orEmpty)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                self.searchText = text
                self.triggerSearch()
            }).disposed(by: disposeBag)
        
        self.searchBar.rx
            .text
            .map { $0?.count == 0 }
            .bind(to: self.iconClose.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.searchBar.rx
            .text
            .map { $0?.count == 0 }
            .bind(to: self.collectionView.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.searchBar.rx
            .text
            .map { $0?.count == 0 }
            .bind(to: self.pageViewController.view.rx.isHidden)
            .disposed(by: disposeBag)
    }
	
	// MARK: - Public Method
	
	convenience init(viewModel: ChannelSearchViewModel) {
		self.init()
		
		self.viewModel = viewModel
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.hideKeyboardWhenTappedAround()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        setupNavbarForPresent()
		view.backgroundColor = .white
        setupSearchBar()
        bindSearchBar()
		bindCollectionView()
		bindPageController()
        
        NotificationCenter.default.addObserver(self, selector: #selector(triggerSearch), name: .notifyReloadChannelSearch, object: nil)
	}
    
    @objc func tappedCancel() {
        ChannelSearchAccountSimpleCache.instance.saveAccounts(accounts: [])
        ChannelSearchContentSimpleCache.instance.saveChannels(accounts: [])
        ChannelSearchTopSimpleCache.instance.saveFeeds(feed: [])
        ChannelSearchTopSimpleCache.instance.saveAccounts(account: [])
        dismiss(animated: false, completion: nil)
    }
	
    @objc func removeText() {
        searchBar.text = .get(.emptyString)
        searchText = .get(.emptyString)
        self.iconClose.isHidden = true
        self.collectionView.isHidden = true
        self.pageViewController.view.isHidden = true
        
        viewControllerList.forEach { controller in
            if let top = controller as? ChannelSearchTopController {
                top.interactor.dataSource.feeds?.removeAll()
                top.interactor.dataSource.accounts?.removeAll()
                top.interactor.dataSource.text = self.searchText
                top.mainView.collectionView.reloadData()
                top.mainView.updateKind(top.interactor.dataSource)
                return
            }
            
            if let account = controller as? ChannelSearchAccountController {
                account.interactor.dataSource.data?.removeAll()
                account.interactor.dataSource.text = self.searchText
                account.mainView.collectionView.reloadData()
                return
            }
            
            if let hashtag = controller as? ChannelSearchHashtagController {
                hashtag.interactor.dataSource.data?.removeAll()
                hashtag.mainView.collectionView.reloadData()
                return
            }
        }
    }
}

// MARK: -  UIGestureRecognizerDelegate

extension ChannelSearchController: UIGestureRecognizerDelegate {
	
	@objc func triggerSearch() {
		guard let currentVC = pageViewController.viewControllers?.first else { return }
		self.viewControllerList.forEach { controller in
			
			if let top = controller as? ChannelSearchTopController {
				if currentVC == top {
                    top.mainView.collectionView.backgroundView = nil
					top.interactor.dataSource.feeds?.removeAll()
                    top.interactor.dataSource.accounts?.removeAll()
                    top.mainView.updateKind(top.interactor.dataSource)
                    top.mainView.collectionView.reloadData()
                    if self.searchText != "" {
                        top.interactor.dataSource.text = self.searchText
                        top.interactor.doRequest(.searchAccount)
                    } else {
                        top.interactor.dataSource.text = ""
                    }
					top.interactor.doRequest(.searchFeed)
                    top.isLoading = true
				}
				
			}
			
			if let account = controller as? ChannelSearchAccountController {
				if currentVC == account {
                    account.mainView.collectionView.backgroundView = nil
					account.interactor.dataSource.data?.removeAll()
					account.mainView.collectionView.reloadData()
                    account.isLoading = true
                    if self.searchText != "" {
                        account.interactor.dataSource.text = self.searchText
                        account.interactor.doRequest(.searchAccount)
                    } else {
                        account.interactor.dataSource.text = ""
                    }
				}
				return
			}
			
			if let hashtag = controller as? ChannelSearchHashtagController {
				if currentVC == hashtag {
                    hashtag.mainView.collectionView.backgroundView = nil
					hashtag.interactor.dataSource.data?.removeAll()
					hashtag.mainView.collectionView.reloadData()
                    if self.searchText != "" {
                        hashtag.interactor.dataSource.text = self.searchText
                        hashtag.interactor.doRequest(.searchHashtag(text: self.searchText))
                    } else {
                        hashtag.interactor.dataSource.text = ""
                    }
				}
				return
			}
		}
	}

}

// MARK: - UIPageViewControllerDelegate & UIPageViewControllerDataSource

extension ChannelSearchController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
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
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		viewControllerList = {
			let accountController = ChannelSearchAccountController(mainView: ChannelSearchAccountView(), dataSource: ChannelSearchAccountModel.DataSource())
			let hashtagController = ChannelSearchHashtagController(mainView: ChannelSearchHashtagView(), dataSource: ChannelSearchHashtagModel.DataSource())
			return [topController, accountController, hashtagController]
		}()
		pageViewController.setViewControllers([viewControllerList[indexPath.item]], direction: .forward, animated: false, completion: nil)
        triggerSearch()
	}
	
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate & UICollectionViewDelegateFlowLayout

extension ChannelSearchController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return menuArray.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCustomCell(with: ChannelSearchItemCell.self, indexPath: indexPath)
		cell.titleLabel.text = menuArray[indexPath.row]
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tabCount = CGFloat(menuArray.count)
        let width = view.frame.width  / tabCount - 10
		return CGSize(width: width, height: 50)
	}
}
