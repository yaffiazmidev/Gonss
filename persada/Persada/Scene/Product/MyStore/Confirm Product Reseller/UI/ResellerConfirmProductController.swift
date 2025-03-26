//
//  ResellerConfirmProductController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 24/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasNetworking

final class ResellerConfirmProductController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isMultipleTouchEnabled = false
        table.tableFooterView = UIView()
        table.backgroundColor = .white
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UITableView.automaticDimension
        table.register(HeaderProductConfirmPriceCell.self, forCellReuseIdentifier: "headerId")
        table.register(ProductPriceConfirmResellerCell.self, forCellReuseIdentifier: "priceId")
        table.register(UsernameConfirmResellerCell.self, forCellReuseIdentifier: "usernameId")
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.accessibilityIdentifier = "tableView-ResellerConfirmProductController"
        return table
    }()
    
    private lazy var saveButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Simpan & Aktifkan Produk Reseller", for: .normal)
        button.isUserInteractionEnabled = false
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .primaryLowTint
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 8
        button.accessibilityIdentifier = "saveButton-ResellerConfirmProductController"
        return button
    }()
    
    private lazy var termLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .Roboto(.regular, size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(
            string: "Dengan menambahkan produk ini, saya menyetujui",
            attributes: [NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.contentGrey]
        )
        
        attributedText.append(NSMutableAttributedString(string: " Syarat & Ketentuan", attributes: [
            NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.secondary
        ]))
        
        attributedText.append(NSMutableAttributedString(string: " dari fitur Produk Reseller", attributes: [
            NSAttributedString.Key.font: UIFont.Roboto(.regular, size: 12), NSAttributedString.Key.foregroundColor: UIColor.contentGrey
        ]))
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        
        label.attributedText = attributedText
        label.accessibilityIdentifier = "termLabel-HeaderProductConfirmPriceCell"
        return label
    }()
    
    private var delegate: ResellerConfirmProductDelegate!
    private var params: ResellerConfirmProductItem?
    var dismissAction: (() -> Void)?
    
    init(delegate: ResellerConfirmProductDelegate, params: ConfirmProductParams) {
        self.delegate = delegate
        self.params = ResellerConfirmProductItem(id: params.id, accountId: params.accountId, productName: params.productName, sellerName: params.sellerName, price: params.price, commission: params.commission, modal: params.modal, isDelete: params.isDelete, imageURL: params.imageURL, username: "", photo: "", isVerified: false, isAlreadyReseller: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestUserSeller()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        hidesBottomBarWhenPushed = false
    }
    
    private func requestUserSeller() {
        guard let accountId = params?.accountId, let productId = params?.id else { return }
        let request = UserSellerRequest(id: accountId)
        delegate.didRequestUserSeller(request: request)
        delegate.didRequestResellerProduct(request: ResellerProductRequest(id: productId))
    }
    
    private func setupView() {
        view.addSubview(tableView)
        view.addSubview(saveButton)
        view.addSubview(termLabel)
        tableView.frame = view.bounds
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            termLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -16),
            termLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 30),
            termLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -30),
            termLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        saveButton.onTap { [weak self] in
            guard let self = self else { return }
            
            self.delegate.didVerifyReseller()
        }
        
        termLabel.onTap { [weak self] in
            guard let self = self else { return }
            
            let browserController = AlternativeBrowserController(url: .get(.kipasKipasPrivacyPolicyUrl))
            browserController.bindNavigationBar(.get(.kebijakanPrivasi), false)
            
            let navigate = UINavigationController(rootViewController: browserController)
            navigate.modalPresentationStyle = .fullScreen
            
            self.present(navigate, animated: true, completion: nil)
        }
    }
    
    private func enableSaveButton() {
        guard let isAlreadyReseller = params?.isAlreadyReseller else {
            return
        }
        
        DispatchQueue.main.async {
            if isAlreadyReseller {
                self.saveButton.isUserInteractionEnabled = false
                self.saveButton.backgroundColor = .primaryLowTint
            } else {
                self.saveButton.isUserInteractionEnabled = true
                self.saveButton.backgroundColor = .primary
            }
        }
    }
}

extension ResellerConfirmProductController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "usernameId", for: indexPath) as! UsernameConfirmResellerCell
            cell.configure(imageURL: params?.photo ?? "", title: "Seller", name: params?.name ?? "", username: "@\(params?.username ?? "")", isVerified: params?.isVerified ?? false)
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "priceId", for: indexPath) as! ProductPriceConfirmResellerCell
            cell.configure(title: "Komisi Reseller", price: params?.commission?.toMoney() ?? 0.toMoney(), desc: "Ini adalah komisi yang didapat oleh reseller jika berhasil menjual produk kamu.")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "headerId", for: indexPath) as! HeaderProductConfirmPriceCell
        cell.configure(imageURL: params?.imageURL ?? "", title: "Produk", subtitle: params?.productName ?? "", price: params?.price?.toMoney() ?? 0.toMoney())
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 120
        } else if indexPath.row == 1 {
            return 85
        }
        
        return UITableView.automaticDimension
    }
}

extension ResellerConfirmProductController: UserSellerView, UserSellerLoadingErrorView {
    func display(_ viewModel: UserSellerViewModel) {
        params?.name = viewModel.item.name
        params?.username = viewModel.item.username
        params?.photo = viewModel.item.photo
        params?.isVerified = viewModel.item.isVerified
        tableView.reloadData()
    }
    
    func display(_ viewModel: UserSellerLoadingErrorViewModel) {

    }
}

extension ResellerConfirmProductController: ResellerConfirmProductView, ResellerConfirmProductLoadingErrorView {
    func display(_ viewModel: ResellerConfirmProductViewModel) {
        navigationController?.popViewController(animated: true)
        dismissAction?()
    }
    
    func display(_ viewModel: ResellerConfirmProductLoadingErrorViewModel) {
        DispatchQueue.main.async {
            Toast.share.show(message: viewModel.message ?? "")
            self.navigationController?.popViewController(animated: true)
        }
        dismissAction?()
    }
}

extension ResellerConfirmProductController: ResellerProductView, ResellerProductLoadingErrorView {
    func display(_ viewModel: ResellerProductViewModel) {
        params?.isAlreadyReseller = viewModel.item.isAlreadyReseller
        DispatchQueue.main.async {
            self.enableSaveButton()
            self.loadViewIfNeeded()
        }
        
    }
    
    func display(_ viewModel: ResellerProductLoadingErrorViewModel) {
    
    }
}

extension ResellerConfirmProductController: ResellerValidatorView, ResellerValidatorLoadingErrorView {
    func display(_ viewModel: ResellerValidatorViewModel) {
        
        if viewModel.item.follower && viewModel.item.totalPost && viewModel.item.shopDisplay {
            self.delegate.didResellerConfirmProduct(request: ResellerProductConfirmRequest(id: self.params?.id ?? ""))
        } else {
            DispatchQueue.main.async {
                let controller = ResellerValidatorUIFactory.create()
                self.present(controller, animated: false)
            }
        }
    }
    
    func display(_ viewModel: ResellerValidatorLoadingErrorViewModel) {
        DispatchQueue.main.async {
            Toast.share.show(message: viewModel.message)
        }
    }
}
