//
//  CategoryShopController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 17/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Foundation

class CategoryShopController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isMultipleTouchEnabled = false
        table.separatorStyle = .singleLine
        table.separatorColor = .whiteSmoke
        table.backgroundColor = .white
        table.allowsSelection = true
        table.rowHeight = 60
        table.showsVerticalScrollIndicator = false
        table.accessibilityIdentifier = "shopTableView-CategoryShopController"
        table.register(CategoryShopCell.self, forCellReuseIdentifier: CategoryShopCell.className)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        return refresh
    }()
    
    private let delegate: CategoryShopControllerDelegate
    
    private var items: [CategoryShopItem] = [CategoryShopItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(delegate: CategoryShopControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        requestCategoryShop()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavigationBar("Kategori")
        navigationController?.displayShadowToNavBar(status: true, .whiteSmoke)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.displayShadowToNavBar(status: false)
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handlePulltoRequest), for: .valueChanged)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func requestCategoryShop() {
        let request = CategoryShopRequest(page: 0, size: 50)
        delegate.didRequestCategoryShop(request: request)
    }
    
    @objc private func handlePulltoRequest() {
        requestCategoryShop()
    }
}

extension CategoryShopController: CategoryShopView, CategoryShopLoadingView, CategoryShopLoadingErrorView {
    
    func display(_ viewModel: CategoryShopViewModel) {
        items = viewModel.items
        refreshControl.endRefreshing()
    }
    
    func display(_ viewModel: CategoryShopLoadingViewModel) {
        
    }
    
    func display(_ viewModel: CategoryShopLoadingErrorViewModel) {
        
    }
}

extension CategoryShopController: UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        let controller = CategoryDetailUIFactory.create(isPublic: !AUTH.isLogin(), categoryProduct: item)
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryShopCell.className, for: indexPath) as! CategoryShopCell
        let item = items[indexPath.row]
        cell.configure(url: item.icon, text: item.name)
        
        return cell
    }
}
