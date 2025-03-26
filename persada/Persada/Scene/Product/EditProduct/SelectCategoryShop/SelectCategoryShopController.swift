//
//  SelectCategoryShopController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 27/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Foundation

class SelectCategoryShopController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isMultipleTouchEnabled = false
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.allowsSelection = true
        table.rowHeight = 60
        table.showsVerticalScrollIndicator = false
        table.accessibilityIdentifier = "shopTableView-CategoryShopController"
        table.register(CategoryShopCell.self, forCellReuseIdentifier: CategoryShopCell.className)
        table.refreshControl = refreshControl
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let searchBar: UITextField = {
        let textfield = UITextField(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.clipsToBounds = true
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
        textfield.layer.cornerRadius = 8
        textfield.clearButtonMode = .always
        textfield.textColor = .grey
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
        ]
        textfield.backgroundColor = UIColor.white
        textfield.attributedPlaceholder = NSAttributedString(string: "Cari Kategori..", attributes: attributes)
        textfield.rightViewMode = .always
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        textfield.leftViewMode = .always
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: 50))
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: String.get(.iconSearchCategory))
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        textfield.rightView = containerView
        textfield.accessibilityIdentifier = "searchBar-CategoryShopController"
        return textfield
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    weak var delegateEditProduct: EditProductController?
    private let delegate: CategoryShopControllerDelegate
    private var items: [CategoryShopItem] = [CategoryShopItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    private var searchItems: [CategoryShopItem] = [CategoryShopItem]() {
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
        navigationController?.displayShadowToNavBar(status: true, .whiteSmoke)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.displayShadowToNavBar(status: false)
    }
    
    @objc
    func handleRefresh() {
        searchBar.text = ""
        requestCategoryShop()
    }
    
    func setupView() {
        title = "Kategori"
        
        searchBar.sizeToFit()
        searchBar.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        view.backgroundColor = .white
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func requestCategoryShop() {
        let request = CategoryShopRequest(page: 0, size: 50)
        delegate.didRequestCategoryShop(request: request)
    }
    
    func dismiss(_ categoryShop: CategoryShopItem?) {
        if let category = categoryShop {
            navigationController?.popViewController(animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegateEditProduct?.setCategory(category: category)
            }
        }
    }
    
    @objc func textChanged(_ textField: UITextField) {
        let currentText = textField.text ?? ""
        if currentText.isEmpty {
            searchItems = items
            return
        }
        searchItems = items.filter { $0.name.localizedStandardContains(currentText) }
        if searchItems.count == 0 {
            tableView.emptyView(
                isEmpty: true,
                title: "Tidak ada kategori yang sesuai dengan pencarian ini",
                subtitle: "Coba kata kunci lain") { [weak self] in
                    self?.searchBar.text = ""
                    self?.searchItems = self?.items ?? []
                    self?.tableView.backgroundView = nil
                    self?.tableView.reloadData()
                    self?.searchBar.becomeFirstResponder()
                }
        } else {
            tableView.backgroundView = nil
        }
    }
}

extension SelectCategoryShopController: CategoryShopView, CategoryShopLoadingView, CategoryShopLoadingErrorView {
    
    func display(_ viewModel: CategoryShopViewModel) {
        items = viewModel.items
        searchItems = viewModel.items
        refreshControl.endRefreshing()
    }
    
    func display(_ viewModel: CategoryShopLoadingViewModel) {
        
    }
    
    func display(_ viewModel: CategoryShopLoadingErrorViewModel) {
        
    }
}

extension SelectCategoryShopController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryShopCell.className, for: indexPath) as! CategoryShopCell
        let item = searchItems[indexPath.row]
        cell.configure(url: item.icon, text: item.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.searchItems[indexPath.row]
        dismiss(item)
    }
}

