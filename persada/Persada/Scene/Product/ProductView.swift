//
//  ProductView.swift
//  Persada
//
//  Created by NOOR on 30/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol ProductViewDelegate where Self: UIViewController {
	func addAddress()
	func refreshUI()
    func showQRReader()
}

class ProductView: UIView {
	
	static let hstackCellId = "hstackCellId"
	static let cellId: String = "cellId"
	static let descriptionChannel: String = "Shop Description"

	private enum ViewTrait {
		static let iconSearch: String = "iconSearch"
		static let placeHolderSearch: String = "Temukan yang kamu mau.."
	}
    
    private enum Section: String,CaseIterable {
        case categoryShop = "category"
        case productShop = "product"
    }

	var delegate: ProductViewDelegate?

	lazy var addressEmptyWarning: UIView = {
		let view: UIView = UIView()
		let label: UILabel = UILabel()
		let button: UIButton = UIButton()

		view.backgroundColor = .primaryLowTint
		view.layer.cornerRadius = 8
		view.addSubview(label)
		view.addSubview(button)

		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.text = "Tambahkan alamat pengiriman untuk mulai jualan di KipasKipas"
		label.textColor = .contentGrey
		label.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingRight: 16)

		let attributedText = NSAttributedString(string: "Tambah Alamat Kirim +", attributes: [NSAttributedString.Key.font: UIFont.Roboto(.medium, size: 12), NSAttributedString.Key.foregroundColor: UIColor.primary])

		button.contentHorizontalAlignment = .leading
		button.addTarget(self, action: #selector(self.addNewAddress), for: .touchUpInside)
		button.setAttributedTitle(attributedText, for: .normal)
		button.anchor(top: label.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
		view.isHidden = true

		return view
	}()

	lazy var searchBar: UITextField = {
		var textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
		textfield.clipsToBounds = true
		textfield.placeholder = ViewTrait.placeHolderSearch
		textfield.layer.borderWidth = 1
		textfield.layer.borderColor = UIColor.whiteSmoke.cgColor
		textfield.layer.cornerRadius = 8
		textfield.textColor = .grey
		let attributes = [
			NSAttributedString.Key.foregroundColor: UIColor.placeholder,
			NSAttributedString.Key.font : UIFont.Roboto(.medium, size: 12) // Note the !
		]
		textfield.backgroundColor = UIColor.white

		textfield.attributedPlaceholder = NSAttributedString(string: ViewTrait.placeHolderSearch, attributes: attributes)
		textfield.rightViewMode = .always

		textfield.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 16))
		textfield.leftViewMode = .always

		let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width:50, height: self.frame.height))
		let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
		imageView.image = UIImage(named: ViewTrait.iconSearch)
		containerView.addSubview(imageView)
		imageView.center = containerView.center
		textfield.rightView = containerView


		return textfield
	}()
    
    lazy private var optionSort: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconSort))!, target: self, action: #selector(handleOptionSort))
        return button
    }()
    
    lazy private var optionFilter: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconFilter))!, target: self, action: #selector(handleOptionFilter))
        return button
    }()
    
    lazy private var optionQRCode: UIButton = {
        let button = UIButton(image: UIImage(named: String.get(.iconQR))!, target: self, action: #selector(handleQRCode))
        return button
    }()
    
    @objc func handleOptionSort() {
        print("I'm Sort")
    }
    
    @objc func handleOptionFilter() {
        print("I'm Filter")
    }
    
    @objc func handleQRCode() {
        delegate?.showQRReader()
    }
	
	lazy var collectionView: UICollectionView = {
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.registerCustomCell(ProductCategoryItemCell.self)
		collectionView.registerCustomCell(ProductItemCell.self)
		collectionView.backgroundColor = .white
		collectionView.refreshControl = refreshController
		collectionView.registerCustomCell(ChannelContentsHeaderCell.self)
		return collectionView
	}()
	
    let emptyStateLabel: UILabel = UILabel(font: .Roboto(.medium, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
    
    lazy var emptyStateView: UIView = {
        let view: UIView = UIView()
        //let label: UILabel = UILabel(font: .Roboto(.medium, size: 14), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        let image: UIImageView = UIImageView(image: UIImage(named: String.get(.iconNotFoundSoft)))
        
        view.addSubview(emptyStateLabel)
        view.addSubview(image)
        
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:0).isActive = true
        emptyStateLabel.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 43.5, paddingRight: 43.5)
        
        image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant:0).isActive = true
        image.anchor(bottom: emptyStateLabel.topAnchor, paddingBottom: 12)
        
        return view
    }()

	
	func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { (section, environment) -> NSCollectionLayoutSection? in
            switch section {
            case 0:
                return self.productSection()
            default:
                fatalError("Unexpected section in collection view")
            }
        }
        
        return layout
	}
	
	lazy var refreshController: UIRefreshControl = {
		let refresh = UIRefreshControl(backgroundColor: .white)
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
		return refresh
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white

		addSubview(searchBar)
//        addSubview(optionSort)
//        addSubview(optionFilter)
        addSubview(optionQRCode)
		addSubview(collectionView)
        addSubview(emptyStateView)
		addSubview(addressEmptyWarning)

		addressEmptyWarning.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16, paddingRight: 16)

        searchBar.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: optionQRCode.leftAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 14, height: 40)
//
//        optionSort.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: optionFilter.leftAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 8,width: 34, height: 34)
        
//        optionFilter.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20,width: 34, height: 34)
        
        optionQRCode.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 8,width: 34, height: 34)
        
		collectionView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
        
        
        emptyStateView.anchor(top: searchBar.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 16, paddingBottom: 0, paddingRight: 16)
        emptyStateView.isHidden = true

	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func updateView(isNotHaveAddress: Bool) {
		if isNotHaveAddress {
			optionQRCode.isHidden = true
			searchBar.isHidden = true
			collectionView.isHidden = true
			addressEmptyWarning.isHidden = false
		} else {
			addressEmptyWarning.isHidden = true
			searchBar.isHidden = false
			collectionView.isHidden = false
			optionQRCode.isHidden = false
		}
	}
	
	@objc private func handlePullToRefresh() {
		self.delegate?.refreshUI()
	}

	@objc func addNewAddress() {
		delegate?.addAddress()
	}
}

extension ProductView {
	private func productSection() -> NSCollectionLayoutSection {
		let inset: CGFloat = 15
		
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: 4, bottom: 8, trailing: 4)
		
		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),heightDimension: .fractionalWidth(0.72))
		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
		
		let section = NSCollectionLayoutSection(group: group)
		
		return section
	}
    
}

