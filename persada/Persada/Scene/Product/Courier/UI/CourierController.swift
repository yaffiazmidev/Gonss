//
//  CourierController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 21/11/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol CourierViewDelegate where Self: UIViewController {

    func dismiss(_ value: Courier, _ index: Int)
}
struct CourierParameter {
    let productId: String
    let addressId: String
    let quantity: Int
}

class CourierController: UIViewController {
    
    private let delegate: CourierViewControllerDelegate
    private let headerSection = "myHeaderView"
    
    var dismissAction: ((_ courier: CourierItem, _ index: Int) -> Void)?
    
    private var items = [CourierItem]() {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 110, right: 0)
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.registerCustomCell(CourierItemCell.self)
        view.register(CourierHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: self.headerSection)

        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }

        return view
    }()
    
    private let imageView = UIImageView(image: UIImage(named: String.get(.iconSuccess)))
    private let labelInfo = UILabel(text: String.get(.orderInfo), font: .Roboto(.medium ,size: 10), textColor: .contentGrey, textAlignment: .left, numberOfLines: 2)
    
    private lazy var infoNotifView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .greenWhite
        view.contentMode = .center
        view.layer.cornerRadius = 4
            
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .success
        labelInfo.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(imageView)
        view.addSubview(labelInfo)
        labelInfo.anchor(top: view.topAnchor, left: imageView.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 12)
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, paddingTop: 15, paddingLeft: 10, paddingBottom: 15)
    
        return view
    }()
    
    private let loading = NVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin, color: .primary, padding: 0)
    private let emptyView = EmptyCourierView(frame: .zero)
    
    private let parameter: CourierParameter
    
    init(delegate: CourierViewControllerDelegate, parameter: CourierParameter) {
        self.delegate = delegate
        self.parameter = parameter
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupLoadingView()
        setupEmptyView()
        requestCourier()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindNavigationBar(.get(.pilihPengiriman))
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    private func startLoading() {
        loading.startAnimating()
    }

    private func stopLoading() {
        loading.stopAnimating()
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .white
        view.addSubview(infoNotifView)
        view.addSubview(collectionView)
        infoNotifView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 50)
        
        collectionView.anchor(top: infoNotifView.safeAreaLayoutGuide.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingRight: 20)
    }
    
    private func setupLoadingView() {
        view.addSubview(loading)
        loading.centerInSuperview(size: CGSize(width: 40, height: 40))
    }
    
    private func setupEmptyView() {
        view.addSubview(emptyView)
        emptyView.isHidden = true
        emptyView.centerInSuperview(size: CGSize(width: 210, height: 180))
        
        emptyView.refreshButton.onTap { [weak self] in
            self?.refresh()
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented, You should't initialize the ViewController through Storyboards")
    }
    
    private func requestCourier() {
        let request: CourierRequest = CourierRequest(addressId: parameter.addressId, productId: parameter.productId, quantity: parameter.quantity)
        delegate.didRequestCouriers(request: request)
    }
    
    private func refresh() {
        requestCourier()
    }
}

extension CourierController:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let itemPriceIsNotNill = items.filter { $0.prices?.count ?? 0 > 0 }.count
        return itemPriceIsNotNill
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemPriceIsNotNill = items.filter { $0.prices?.count ?? 0 > 0 }
        return itemPriceIsNotNill[section].prices?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.headerSection, for: indexPath) as! CourierHeaderCell
            
            let validItem = items.filter { $0.prices?.count ?? 0 > 0 }
            
            if validItem[indexPath.section].prices?.count != 0 {
                headerView.name = validItem[indexPath.section].name
            }
            return headerView
            
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60.0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCustomCell(with: CourierItemCell.self, indexPath: indexPath)

        let validItem = items.filter { $0.prices?.count ?? 0 > 0 }
        let itemSection = validItem[indexPath.section]
        
        guard let item = itemSection.prices?[indexPath.row] else {
            return cell
        }
        
        cell.item = item

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 16
        return CGSize(width: width, height: 47)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let itemPriceIsNotNill = items.filter { $0.prices?.count ?? 0 > 0 }
        let courier = itemPriceIsNotNill[indexPath.section]

        dismissAction?(courier, indexPath.row)
        navigationController?.popViewController(animated: false)
    }
}

extension CourierController: CourierView, CourierLoadingView, CourierLoadingErrorView {
    
    func display(_ viewModel: CourierViewModel) {
        items.append(contentsOf: viewModel.items)
    }
    
    func display(_ viewModel: CourierLoadingViewModel) {
        if viewModel.isLoading {
            startLoading()
        } else {
            stopLoading()
        }
    }
    
    func display(_ viewModel: CourierLoadingErrorViewModel) {
        
        showInfoView(when: viewModel.message != nil)
    }
    
    private func showInfoView(when isShow: Bool) {
        emptyView.isHidden = !isShow
        infoNotifView.isHidden = isShow
    }
}

