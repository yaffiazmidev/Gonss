//
//  ProfileSelebController.swift
//  Persada
//
//  Created by Muhammad Noor on 14/04/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import ContextMenu

private let headerIdentifier = "ProfileHeader"
private let cellId: String = "cellId"

class ProfileSelebController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Public Property
    
    let headerProfileUser: ProfileSelebUserHeaderView = {
        let viewUser = ProfileSelebUserHeaderView()
        viewUser.translatesAutoresizingMaskIntoConstraints = false
        return viewUser
    }()
    
    let collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var buttonPost: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        button.backgroundColor = UIColor.init(hexString: "#BC1C22", alpha: 1)
        button.layer.masksToBounds = false
        button.setImage(#imageLiteral(resourceName: "Unionplus"), for: .normal)
        button.addTarget(self, action: #selector(handleWhenTappedPostButton), for: .touchUpInside)
        return button
    }()
    
    lazy var containerView: UIView = {
        let layout = UIView()
        layout.backgroundColor = .white
        layout.translatesAutoresizingMaskIntoConstraints = false
        return layout
    }()
    
    var temp = 0
    let menuArray = [ "Post", "Events" ]
    var heightProfileUser: CGFloat = 180
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var viewControllerList: [UIViewController]!
    var id: String = ""
    var type: String = ""
    var heightHeader = 230
    var viewModel: ProfileViewModel?
    
    // MARK: - Public Method
    
    convenience init(id: String, type: String, viewModel: ProfileViewModel) {
        self.init()
        
        self.id = id
        self.type = type
        self.viewModel = viewModel
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func didSelectionOption() {
        let profileMenu = ProfileMenuContext()
        
        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: profileMenu,
            options: ContextMenu.Options(
                containerStyle: ContextMenu.ContainerStyle(
                    backgroundColor: .white
                ),
                menuStyle: .default,
                hapticsStyle: .medium
            ),
            sourceView: headerProfileUser.buttonMoreOption,
            delegate: self
        )
    }
    
    func bindPageController() {
        viewControllerList = {
            
            let postViewModel = ProfilePostViewModel(id: id, type: type, networkModel: ProfileNetworkModel())
            let profilePost = ProfilePostController(viewModel: postViewModel)
            return [profilePost]
        }()
        
        view.addSubview(containerView)
        containerView.anchor(top: collectionView.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), size: CGSize(width: 0, height: 0))
        
        // Setup: UIPageViewController
        pageViewController.automaticallyAdjustsScrollViewInsets = false
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.setViewControllers([viewControllerList[temp]], direction: .forward, animated: true)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        pageViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        pageViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        pageViewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        pageViewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        pageViewController.setViewControllers([viewControllerList[temp]], direction: .forward, animated: true)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(headerProfileUser)
        headerProfileUser.handleProfileMenu = didSelectionOption
        headerProfileUser.handleFollow = handleFollow(_:)
        headerProfileUser.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(), size: CGSize(width: 0, height: heightProfileUser))
        
        bindCollectionView()
        bindPageController()
        
        buttonPost.isHidden = getIdUser() != id
        
        view.addSubview(buttonPost)
        buttonPost.anchor(top: nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 20, paddingRight: 20, width: 50, height: 50)
    }
    
    @objc func handleWhenTappedPostButton() {
        let profileMenu = ProfilePostMenuContext()

        ContextMenu.shared.show(
            sourceViewController: self,
            viewController: profileMenu,
            options: ContextMenu.Options(menuStyle: .minimal, hapticsStyle: .medium)
        )
    }
    
    func handleFollow(_ id: String) {
        viewModel?.id = id
        viewModel?.followUser()
    }
    
    func bindViewModel() {
        
        viewModel?.changeHandler = { [weak self] change in
            
            guard let self = self else {
                return
            }
            
            switch change {
            case .didEncounterError(let error):
                print(error?.statusMessage ?? "")
            case .didUpdateProfile(let response):
                DispatchQueue.main.async {
                    self.headerProfileUser.item = response
                    self.view.layoutIfNeeded()
                }
            case .didUpdateProfileFollowAccount:
                self.viewModel?.fetchProfile()

                DispatchQueue.main.async {
                    self.view.layoutIfNeeded()
                }
            case .didUpdateTotalFollowers(let value):
                
                DispatchQueue.main.async {
                    self.headerProfileUser.followers = value
                    self.view.layoutIfNeeded()
                }
            case .didUpdateTotalFollowings(let value):
                DispatchQueue.main.async {
                    self.headerProfileUser.followings = value
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    // MARK: - Private Method
    
    func bindCollectionView()  {
        
        view.addSubview(collectionView)
        collectionView.anchor(top: headerProfileUser.bottomAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0), size: CGSize(width: view.frame.width, height: 50))
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.reloadData()
        collectionView.selectItem(at: IndexPath(item: temp, section: 0), animated: true, scrollPosition: .left)
        
        guard let tabHeight = tabBarController?.tabBar.frame.height else { return }
        collectionView.contentInset.bottom = tabHeight
    }
}

// MARK: - UIPageViewControllerDelegate & UIPageViewControllerDataSource

extension ProfileSelebController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
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

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension ProfileSelebController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ProfileFilterCell
        cell.titleLabel.text = menuArray[indexPath.row]
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileSelebController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width  / 2 - 20
        return CGSize(width: width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewControllerList = {
            let postViewModel = ProfilePostViewModel(id: id, type: type, networkModel: ProfileNetworkModel())
            let profilePost = ProfilePostController(viewModel: postViewModel)
            return [profilePost]
        }()
        
        pageViewController.setViewControllers([viewControllerList[indexPath.item]], direction: .forward, animated: false, completion: nil)
    }
}

extension ProfileSelebController: ContextMenuDelegate {
    
    //MARK: ContextMenuDelegate
    func contextMenuWillDismiss(viewController: UIViewController, animated: Bool) {
        print("will dismiss")
    }
    
    func contextMenuDidDismiss(viewController: UIViewController, animated: Bool) {
        print("did dismiss")
    }
}
