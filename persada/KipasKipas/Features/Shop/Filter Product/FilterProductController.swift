//
//  FilterProductController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 20/01/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

class FilterProductController: UIViewController {
    
    private lazy var flowLayout: DENCollectionViewLayout = {
        let layout = DENCollectionViewLayout()
        layout.columnCount = 2
        layout.minimumColumnSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        
        view.register(FilterProductCell.self, forCellWithReuseIdentifier: FilterProductCell.className)
        view.dataSource = self
        view.delegate = self
        return view
    }()
    
    let searchBar: UITextField = {
        let textfield = UITextField(frame: .zero)
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.clipsToBounds = true
        textfield.placeholder = "Cari"
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
        textfield.layer.cornerRadius = 8
        textfield.textColor = .grey
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.placeholder,
            NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
        ]
        textfield.backgroundColor = UIColor.whiteSnow
        textfield.attributedPlaceholder = NSAttributedString(string: .get(.findChat), attributes: attributes)
        textfield.rightViewMode = .always
        textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
        textfield.leftViewMode = .always
        
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: 50))
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        imageView.image = UIImage(named: String.get(.iconSearch))
        containerView.addSubview(imageView)
        imageView.center = containerView.center
        textfield.rightView = containerView
        textfield.accessibilityIdentifier = "searchBar-FilterProductController"
        return textfield
    }()
    
    private var productCategoryId: String? = nil
    private var searchText = ""
    private let delegate: FilterProductControllerDelegate
    private var items: [FilterProductViewModel] = [FilterProductViewModel]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    init(delegate: FilterProductControllerDelegate, productCategoryId: String? = nil) {
        self.delegate = delegate
        self.productCategoryId = productCategoryId
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        requestSearchProduct()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        title = "Kategori"
        
        searchBar.sizeToFit()
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        
        view.backgroundColor = .whiteSmoke
        view.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.safeAreaLayoutGuide.bottomAnchor, constant: 18),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func requestSearchProduct() { }
}

extension FilterProductController: FilterProductView, FilterProductLoadingView, FilterProductLoadingErrorView {
    
    func display(_ viewModel: [FilterProductViewModel]) {
        items.append(contentsOf: viewModel)
    }
    
    func display(_ viewModel: FilterProductLoadingViewModel) {
        
    }
    
    func display(_ viewModel: FilterProductLoadingErrorViewModel) {
        
    }
}

extension FilterProductController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        items = items.filter { $0.name.range(of: currentText, options: .caseInsensitive) != nil }
        if items.count == 0 && currentText.isEmpty == true {
        }
        collectionView.reloadData()
        return true
    }
}

extension FilterProductController: DENCollectionViewDelegateLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if items.indices.contains(indexPath.row) {
            let item = items[indexPath.row]
            let heightImage = item.metadataHeight
            let widthImage = item.metadataWidth
            let width = collectionView.frame.size.width - 4
            let scaler = width / widthImage
            let percent = Double((10 - ((indexPath.row % 3) + 1))) / 10
            var height = heightImage * scaler
            if height > 500 {
                height = 500
            }
            height = (height * percent) + 200
            return CGSize(width: width, height: height)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetsFor section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 0)
    }
}

extension FilterProductController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterProductCell.className, for: indexPath) as! FilterProductCell
        let item = items[indexPath.row]
        cell.setup(imageURL: item.imageURL, text: item.name)
        return cell
    }
}
