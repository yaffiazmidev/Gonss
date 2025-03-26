//
//  ProductDetailViewNew.swift
//  KipasKipas
//
//  Created by Azam Mukhtar on 25/03/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class ProductDetailView : UIView {
	
    var reviewCollectionViewHeightAnchor = NSLayoutConstraint()
    var reviewMediaCollectionViewHeightAnchor = NSLayoutConstraint()
    var tanyaPenjualButtonHeightAnchor = NSLayoutConstraint()
    var jadiResellerButtonHeightAnchor = NSLayoutConstraint()
	let scrollView = UIScrollView()
	let contentView = UIView()
	var item: Product?
	
	var handleOption: (() -> Void)?
	var onClickBack: (() -> Void)?
    var onTapLihatLiveProduct: (() -> Void)?
    var onClickTanyaPenjual: (() -> Void)?
    var onClickJadiReseller: (() -> Void)?
    var onClickUpdateStockProduct: (() -> Void)?
	
	lazy var imageSlider : UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
		let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 320), collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
		collection.collectionViewLayout = layout
		collection.backgroundColor = .white
		collection.isPagingEnabled = true
		collection.backgroundView = UIView.init(frame: CGRect.zero)
		collection.register(ImageCell.self, forCellWithReuseIdentifier: String.get(.cellID))
		collection.showsHorizontalScrollIndicator = false
        collection.isUserInteractionEnabled = true
		return collection
	}()
    
    lazy var pageController: UIPageControl = {
        let page = UIPageControl()
        page.translatesAutoresizingMaskIntoConstraints = false
        page.pageIndicatorTintColor = .gainsboro
        page.currentPageIndicatorTintColor = .primary
        page.currentPage = 0
        page.transform = CGAffineTransform(scaleX: 1, y: 1)
        page.isUserInteractionEnabled = false
        return page
    }()
	
	lazy var buyView: BuyButtonView = {
        let view = BuyButtonView.loadViewFromNib()
        view.buyButton.backgroundColor = .gradientStoryOne
		return view
	}()
	
	lazy var lineView: UIView = {
		let view: UIView = UIView()
		view.backgroundColor = UIColor.white
		view.layer.shadowColor = UIColor.black25.cgColor
		view.layer.shadowOpacity = 0.4
		view.layer.shadowOffset = CGSize(width: 0, height: -3)
		view.layer.shadowRadius = 0.5
		view.isHidden = true
		return view
	}()
	
	lazy var emptyLabel: UILabel = {
		let label: UILabel = UILabel()
        label.numberOfLines = 0
		label.font = .Roboto(.regular, size: 14)
        label.text = .get(.failBuyingProduct) + "\n\n"
		label.textColor = .placeholder
		label.textAlignment = .center
		label.isHidden = true
		return label
	}()
    
    lazy var navBarContainer: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = UIColor.white
        view.shadowColor = UIColor.black25
        view.setShadowOpacity = 0.4
        view.shadowOffset = CGSize(width: 0, height: 3)
        view.setShadowRadius = 3
        view.layer.masksToBounds = false
        return view
    }()
	
	lazy var buttonLeft: UIButton = {
		let image = UIImage(named: .get(.iconBack))?.withRenderingMode(.alwaysOriginal)
		let button = UIButton(image: image!, target: self, action: #selector(onClickBackFunc))
		button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		button.layer.cornerRadius = 0.5 * button.bounds.size.width
		button.clipsToBounds = true
		button.layer.masksToBounds = false
		button.backgroundColor = UIColor.black25
		return button
	}()

	lazy var buttonRight: UIButton = {
		let image = UIImage(named: .get(.iconKebab))?.withRenderingMode(.alwaysOriginal)
		let button = UIButton(image: image!, target: self, action: #selector(handleOptionFunc))
		button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
		button.layer.cornerRadius = 0.5 * button.bounds.size.width
		button.clipsToBounds = true
		button.layer.masksToBounds = false
		button.backgroundColor = UIColor.black25
		return button
	}()
	
	let itemNameLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.medium, size: 18), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let itemPriceLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.bold, size: 16), textColor: .gradientStoryOne, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

    let commissionLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.bold, size: 10), textColor: .primary, textAlignment: .center, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()

	lazy var ratingLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "4.5 (19)"
		return label
	}()

	lazy var ratingBarView: CosmosView = {
		let view = CosmosView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.rating = 4.5

		let gold = UIColor(hexString: "#FFBC10")
		view.settings.filledColor = gold
		view.settings.emptyBorderColor = gold
		view.settings.filledBorderColor = gold

		view.settings.fillMode = .precise
		view.settings.updateOnTouch = false
		view.settings.starMargin = 0
		view.settings.starSize = 14
		view.settings.emptyImage = UIImage(named: .get(.iconProductStarEmpty))
		view.settings.filledImage = UIImage(named: .get(.iconProductStarFill))

		return view
	}()

	lazy var verticalDividerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .contentGrey
		view.widthAnchor.constraint(equalToConstant: 1).isActive = true
		view.heightAnchor.constraint(equalToConstant: 12).isActive = true
		return view
	}()
    
    lazy var totalSalesView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubViews([totalSalesLabel, totalSalesCountLabel])
        totalSalesLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        totalSalesCountLabel.anchor(top: view.topAnchor, left: totalSalesLabel.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        return view
    }()

	lazy var totalSalesLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = "Terjual "
		return label
	}()
    
    lazy var totalSalesCountLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.medium, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "98"
        return label
    }()

    lazy var commissionStackView: UIStackView = {
        let container = UIStackView()
        container.distribution = .fill
        container.alignment = .center

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.backgroundColor = .gainsboro
        container.addArrangedSubviews([commissionView, spacer])

        spacer.setContentCompressionResistancePriority(UILayoutPriority(240), for: .horizontal)
        spacer.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        container.accessibilityIdentifier = "commissionStackView-ProductDetailView"
        return container
    }()

	lazy var ratingSalesView: UIStackView = {
		let container = UIStackView()
		container.spacing = 8
		container.distribution = .fill
		container.alignment = .center

		let spacer = UIView()
		container.addArrangedSubviews([ratingLabel, ratingBarView, verticalDividerView, totalSalesView, spacer])
        ratingBarView.centerYTo(container.centerYAnchor)

		spacer.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
		spacer.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)

		return container
	}()

	lazy var locationLabelView: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		label.text = ""
		return label
	}()

	lazy var locationView: UIView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: .get(.iconProductLocation))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubViews([imageView, locationLabelView])
        imageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor)
        locationLabelView.anchor(top: view.topAnchor, left: imageView.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 2)
        
        return view
    }()

    lazy var commissionView: UIView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: .get(.iconProductReseller))?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center

        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubViews([imageView, commissionLabel])
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 8)
        ])

        NSLayoutConstraint.activate([
            commissionLabel.topAnchor.constraint(equalTo: view.topAnchor),
            commissionLabel.leadingAnchor.constraint(equalTo: imageView.safeAreaLayoutGuide.trailingAnchor, constant: 4),
            commissionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            commissionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            commissionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        view.backgroundColor = .primary
        view.setCornerRadius = 10
        view.isHidden = true
        return view
    }()

	lazy var ratingSalesLocationView: UIStackView = {
		let container = UIStackView()
		container.spacing = 6
		container.axis = .vertical
		container.distribution = .fill
		container.alignment = .leading
		container.addArrangedSubviews([ratingSalesView, locationView])

		return container
	} ()
	
	let shopLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
		label.text = "Shop"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let shopNameLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .secondary, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let descLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
		label.text = "Deskripsi"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let descContentLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
    
    let stockLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
        label.text = "Jumlah Stok Tersedia"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let stockContentLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
	
	let dimensionLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
		label.text = "Dimensi"
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	let dimensionContentLabel: UILabel = {
		let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

    let beratLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
        label.text = "Berat"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let beratContentLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let categoryProductLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .left, numberOfLines: 0)
        label.text = "Kategori"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let categoryProductContentLabel: UILabel = {
        let label: UILabel = UILabel(font: .Roboto(.regular, size: 14), textColor: .black, textAlignment: .left, numberOfLines: 0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let tanyaPenjualButton : UIButton = {
        let button = UIButton()
        button.setTitle("Tanya Penjual", for: .normal)
        button.setTitleColor(.primary, for: .normal)
        button.tintColor = .primary
        button.backgroundColor = .white
        button.titleLabel?.font = .Roboto(.regular, size: 14)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.primary.cgColor
        return button
    }()

    let jadiResellerButton : UIButton = {
        let button = UIButton()
        button.setTitle("+ Jadi Reseller Product ini ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.backgroundColor = .primary
        button.titleLabel?.font = .Roboto(.regular, size: 14)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.primary.cgColor
        return button
    }()

	lazy var updateStockView: UpdateStockButtonView = {
		let view = UpdateStockButtonView.loadViewFromNib()
		view.updateButton.backgroundColor = .gradientStoryOne
		return view
	}()

    lazy var reviewView: ProductReviewView = {
        let view = ProductReviewView.loadViewFromNib()
        view.isHidden = true
        view.mediaCollectionView.showAnotherView = true
        view.collectionView.showMedia = false
        view.collectionView.handleHeightUpdated = { [weak self] in
            self?.updateReviewHeight()
        }
        view.mediaCollectionView.handleHeightUpdated = { [weak self] (_) in
            self?.updateReviewMediaHeight()
        }
        return view
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .primary
        return refresh
    }()
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		scrollView.showsVerticalScrollIndicator = false
		scrollView.fillSuperview()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
		self.addSubview(scrollView)
		scrollView.addSubview(contentView)
		
		scrollView.anchor(top: scrollView.superview?.topAnchor, left: nil, bottom: scrollView.superview?.bottomAnchor, right: scrollView.superview?.rightAnchor)
		scrollView.centerXAnchor.constraint(equalTo: scrollView.superview!.centerXAnchor).isActive = true
		scrollView.widthAnchor.constraint(equalTo: scrollView.superview!.widthAnchor).isActive = true
		scrollView.heightAnchor.constraint(equalTo: scrollView.superview!.heightAnchor).isActive = true
		
		contentView.anchor(top: scrollView.topAnchor, left: nil, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
		contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
		contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
		
		contentView.addSubview(imageSlider)
        contentView.addSubview(pageController)
		updateStockView.isHidden = true
		[itemNameLabel, itemPriceLabel, commissionStackView, ratingSalesLocationView, shopLabel, shopNameLabel, descLabel, descContentLabel, stockLabel, stockContentLabel, dimensionLabel, dimensionContentLabel, beratLabel, beratContentLabel, categoryProductLabel, categoryProductContentLabel, tanyaPenjualButton, jadiResellerButton].forEach { (view) in
			contentView.addSubview(view)
			view.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 20, paddingRight: 20)
		}
        contentView.addSubview(reviewView)
        
        if hasTopNotch {
            imageSlider.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: -47, height: 447)
        } else {
            imageSlider.anchor(top: contentView.topAnchor, left: contentView.leftAnchor, right: contentView.rightAnchor, paddingTop: -20, height: 400)
        }
        
		imageSlider.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pageController.anchor(bottom: imageSlider.bottomAnchor, paddingBottom: 8, height: 8)
        pageController.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

		itemNameLabel.anchor(top: imageSlider.bottomAnchor, paddingTop: 20)
		itemPriceLabel.anchor(top: itemNameLabel.bottomAnchor, paddingTop: 5)
        commissionStackView.anchor(top: itemPriceLabel.bottomAnchor, paddingTop: 8, height: 20)
        ratingSalesLocationView.anchor(top: commissionStackView.bottomAnchor, paddingTop:24)
		shopLabel.anchor(top: ratingSalesLocationView.bottomAnchor, paddingTop:24)
		shopNameLabel.anchor(top: shopLabel.bottomAnchor, paddingTop: 6)
		descLabel.anchor(top: shopNameLabel.bottomAnchor, paddingTop: 20)
		descContentLabel.anchor(top: descLabel.bottomAnchor, paddingTop: 6)
		stockLabel.anchor(top: descContentLabel.bottomAnchor, paddingTop: 20)
		stockContentLabel.anchor(top: stockLabel.bottomAnchor, paddingTop: 6)
		dimensionLabel.anchor(top: stockContentLabel.bottomAnchor, paddingTop: 20)
		dimensionContentLabel.anchor(top: dimensionLabel.bottomAnchor, paddingTop: 6)
		beratLabel.anchor(top: dimensionContentLabel.bottomAnchor, paddingTop: 20)
		beratContentLabel.anchor(top: beratLabel.bottomAnchor, paddingTop: 6)
        categoryProductLabel.anchor(top: beratContentLabel.bottomAnchor, paddingTop: 20)
        categoryProductContentLabel.anchor(top: categoryProductLabel.bottomAnchor, paddingTop: 6)
		tanyaPenjualButton.anchor(top: categoryProductContentLabel.bottomAnchor, paddingTop: 24)
        tanyaPenjualButtonHeightAnchor = tanyaPenjualButton.heightAnchor.constraint(equalToConstant: 0)
        tanyaPenjualButtonHeightAnchor.isActive = true
        jadiResellerButton.anchor(top: tanyaPenjualButton.bottomAnchor, paddingTop: 12)
        jadiResellerButtonHeightAnchor = jadiResellerButton.heightAnchor.constraint(equalToConstant: 40)
        jadiResellerButtonHeightAnchor.isActive = true
        reviewView.anchor(top: jadiResellerButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, paddingTop: 24, paddingBottom: 100)
        reviewCollectionViewHeightAnchor = reviewView.collectionView.heightAnchor.constraint(equalToConstant: 0)
        reviewMediaCollectionViewHeightAnchor = reviewView.mediaCollectionView.heightAnchor.constraint(equalToConstant: 0)
        reviewCollectionViewHeightAnchor.isActive = true
        reviewMediaCollectionViewHeightAnchor.isActive = true
        
        [emptyLabel].forEach { (view) in
			view.translatesAutoresizingMaskIntoConstraints = false
			emptyLabel.backgroundColor = .white
			addSubview(view)
		}
        
        addSubview(buyView)
		addSubview(updateStockView)
		addSubview(lineView)
        addSubview(navBarContainer)
		addSubview(buttonRight)
		addSubview(buttonLeft)
		
		
        navBarContainer.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, height: hasTopNotch ? 105 : 80)
        
		buttonLeft.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
		buttonRight.anchor(top: safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 40, height: 40)
		
		buyView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: 64)

		updateStockView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, height: 64)

		lineView.anchor(left: leftAnchor, bottom: emptyLabel.topAnchor, right: rightAnchor, paddingBottom: 0, height: 0.5)
        emptyLabel.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: 64)
		
	
        tanyaPenjualButton.onTap {
            self.onClickTanyaPenjual?()
        }

        jadiResellerButton.onTap { [weak self] in
            guard let self = self else { return }
            self.onClickJadiReseller?()
        }

		updateStockView.handleUpdate = {
			self.onClickUpdateStockProduct?()
		}
        
        bringSubviewToFront(buyView)
		bringSubviewToFront(updateStockView)
	}
    
    private var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
	
	@objc
	func onClickBackFunc(){
		self.onClickBack?()
	}
	
	@objc
	func handleOptionFunc(){
		self.handleOption?()
	}

    func updateView(isProductUser: Bool, isPreview: Bool = false) {
        let stock = Int(stockContentLabel.text ?? "0")
        if isPreview {
            buyView.isHidden = true
            emptyLabel.isHidden = false
            lineView.isHidden = false
            emptyLabel.text = .get(.lihatLiveProduct) + "\n\n"
            emptyLabel.textColor = .primary
            emptyLabel.isUserInteractionEnabled = true
            tanyaPenjualButton.isHidden = true
            tanyaPenjualButtonHeightAnchor.constant = 0
            updateStockView.isHidden = true
            emptyLabel.onTap {
                self.onTapLihatLiveProduct?()
            }
        } else if isProductUser {
            if stock == 0 {
                buyView.isHidden = true
                emptyLabel.isHidden = true
                lineView.isHidden = true
                tanyaPenjualButton.isHidden = true
                tanyaPenjualButtonHeightAnchor.constant = 0
				updateStockView.isHidden = false
                return
            }
            buyView.isHidden = true
			emptyLabel.isHidden = false
			lineView.isHidden = false
            tanyaPenjualButton.isHidden = true
            tanyaPenjualButtonHeightAnchor.constant = 0
			updateStockView.isHidden = true
            emptyLabel.text = .get(.failBuyingProduct) + "\n\n"
            emptyLabel.textColor = .placeholder
            emptyLabel.isUserInteractionEnabled = false
        } else {
            if stock == 0 {
                buyView.isHidden = true
                emptyLabel.isHidden = false
                lineView.isHidden = false
                tanyaPenjualButton.isHidden = true
                tanyaPenjualButtonHeightAnchor.constant = 0
				updateStockView.isHidden = true
                emptyLabel.text = .get(.stockEmpty) + "\n\n"
                emptyLabel.textColor = .placeholder
                emptyLabel.isUserInteractionEnabled = false
                return
            }
            buyView.isHidden = false
			emptyLabel.isHidden = true
            tanyaPenjualButton.isHidden = false
            tanyaPenjualButtonHeightAnchor.constant = 40
			updateStockView.isHidden = true
			lineView.isHidden = true
		}
	}

    func handleCommission(item: Product) {
        let isResellerAllowed: Bool = item.isResellerAllowed ?? false
        let typeProduct: String = item.type ?? "ORIGINAL"
        let isAccountId: Bool = item.accountId?.isItUser() ?? false
        let isOriginalAccountId: Bool = item.originalAccountId?.isItUser() ?? false
        let isAlreadyReseller: Bool = item.isAlreadyReseller ?? false

        if !isResellerAllowed && typeProduct == "ORIGINAL" && isAccountId && isOriginalAccountId && !isAlreadyReseller {
            itemPriceLabel.text = item.price?.toMoney()
            commissionView.isHidden = true
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = true
            buyView.isHidden = true
        } else if isResellerAllowed && typeProduct == "ORIGINAL" && isAccountId && isOriginalAccountId && !isAlreadyReseller {
            itemPriceLabel.text = item.price?.toMoney()
            commissionView.isHidden = false
            commissionLabel.text = .get(.productReseller)
            commissionView.backgroundColor = .grey
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = true
            buyView.isHidden = true
        } else if isResellerAllowed && typeProduct == "RESELLER" && isAccountId && !isOriginalAccountId && isAlreadyReseller {
            let price = (item.modal ?? 0) + (item.commission ?? 0)
            itemPriceLabel.text = price.toMoney()
            commissionView.isHidden = false
            commissionLabel.text = "Komisi : \(item.commission?.toMoney() ?? "RP 0")"
            commissionView.backgroundColor = .primary
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = true
        } else if !isResellerAllowed && typeProduct == "ORIGINAL" && !isAccountId && !isOriginalAccountId && !isAlreadyReseller {
            itemPriceLabel.text = item.price?.toMoney()
            commissionView.isHidden = true
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = false
        } else if isResellerAllowed && typeProduct == "ORIGINAL" && !isAccountId && !isOriginalAccountId && !isAlreadyReseller {
            itemPriceLabel.text = item.price?.toMoney()
            commissionView.isHidden = false
            commissionLabel.text = "Komisi : \(item.commission?.toMoney() ?? "RP 0")"
            commissionView.backgroundColor = .primary
            jadiResellerButton.isHidden = false
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = false
        } else if isResellerAllowed && typeProduct == "RESELLER" && !isAccountId && !isOriginalAccountId && !isAlreadyReseller {
            let price = (item.modal ?? 0) + (item.commission ?? 0)
            itemPriceLabel.text = price.toMoney()
            commissionView.isHidden = true
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = false
        } else if isResellerAllowed && typeProduct == "RESELLER" && !isAccountId && !isOriginalAccountId && isAlreadyReseller {
            let price = (item.modal ?? 0) + (item.commission ?? 0)
            itemPriceLabel.text = price.toMoney()
            commissionView.isHidden = true
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = false
        } else if isResellerAllowed && typeProduct == "RESELLER" && !isAccountId && isOriginalAccountId && !isAlreadyReseller {
            let price = (item.modal ?? 0) + (item.commission ?? 0)
            itemPriceLabel.text = price.toMoney()
            commissionView.isHidden = false
            commissionLabel.text = "Komisi : \(item.commission?.toMoney() ?? "RP 0")"
            commissionView.backgroundColor = .primary
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = true
            buyView.isHidden = true
        } else if isResellerAllowed && typeProduct == "ORIGINAL" && !isAccountId && !isOriginalAccountId && isAlreadyReseller {
            itemPriceLabel.text = item.price?.toMoney()
            commissionView.isHidden = false
            commissionLabel.text = "Komisi : \(item.commission?.toMoney() ?? "RP 0")"
            commissionView.backgroundColor = .grey
            jadiResellerButton.isHidden = true
            tanyaPenjualButton.isHidden = false
            buyView.isHidden = false
        }
    }

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	func updateData(product: Product){
		itemNameLabel.text = product.name
		itemPriceLabel.text = product.price?.toMoney()
        commissionLabel.text = "Komisi : \(product.commission?.toMoney() ?? "RP 0")"
		descContentLabel.text = product.postProductDescription
        stockContentLabel.text = "\(product.stock ?? 0)"
		
		let length = product.measurement?.length ?? 0
		let widht = product.measurement?.width ?? 0
		let height = product.measurement?.height ?? 0
		dimensionContentLabel.text = "\(length) cm x \(widht) cm x \(height) cm".replacingOccurrences(of: ".0", with: "")
        beratContentLabel.text = "\(product.measurement?.weight ?? 0) kg"
        categoryProductContentLabel.text = product.categoryName

		setupRatingSalesLocationView(product)
        handleCommission(item: product)
	}
    
    func updateUsername(product: Product) {
        shopNameLabel.text = "@\(product.sellerName ?? "")"
    }

	private func setupRatingSalesLocationView(_ product: Product){
		setupLocationView(product.city)
		hideRatingSalesViewWhenEmpty(product.ratingAverage ?? 0, product.totalSales ?? 0) {
			let ratingAverage = product.ratingAverage ?? 0
			let ratingCount = product.ratingCount ?? 0
			let totalSales = product.totalSales ?? 0

			setupTotalSalesView(totalSales)
			setupRatingView(ratingAverage, ratingCount)

			let ratingOrSalesEmpty = ratingLabel.isHidden || totalSalesView.isHidden
			verticalDividerView.isHidden = ratingOrSalesEmpty
		}
	}

	private func setupLocationView(_ city: String?){
		if city.isNilOrEmpty{
			locationView.isHidden = true
		}else{
            locationView.isHidden = false
            locationLabelView.text = city?.capitalized ?? ""
		}
	}

	private func hideRatingSalesViewWhenEmpty(_ rating: Double, _ totalSales: Int, whenNotEmpty: () -> Void ){
		let ratingEmpty = rating == 0
		let totalSalesEmpty = totalSales < 0
		if ratingEmpty && totalSalesEmpty{
			ratingSalesView.isHidden = true
			return
		}
		whenNotEmpty()
	}

	private func setupTotalSalesView(_ totalSales: Int){
		if totalSales < 1 {
			totalSalesView.isHidden = true
		}else{
            totalSalesCountLabel.text = "\(totalSales)"
		}
	}

	private func setupRatingView(_ rating: Double, _ reviewCount: Int){
		if rating == 0 {
			ratingLabel.isHidden = true
			ratingBarView.isHidden = true
		}else{
			ratingLabel.text = "\(rating) (\(reviewCount))"
			ratingBarView.rating = rating
		}
	}
    
    func loadReview(_ review: Review){
        reviewView.isHidden = review.reviews?.isEmpty ?? true
        reviewView.ratingAverageLabel.text = "\(review.ratingAverage ?? 0.0)"
        reviewView.ratingCountLabel.text = "\(review.ratingCount ?? 0) rating"
        reviewView.reviewCountLabel.text = "\(review.reviewCount ?? 0) ulasan"
        reviewView.collectionView.isHidden = false
        reviewView.mediaCollectionView.isHidden = true
        reviewView.collectionView.setData(review.reviews ?? [])
        updateReviewHeight()
    }
    
    func updateReviewHeight(){
        if reviewView.isHidden {
            reviewCollectionViewHeightAnchor.constant = 0
            return
        }
        let contentHeight = reviewView.collectionView.collectionViewLayout.collectionViewContentSize.height
        reviewCollectionViewHeightAnchor.constant = contentHeight
    }
    
    
    func loadMediaReview(_ items: [ReviewMedia]){
        reviewView.mediaCollectionView.isHidden = false
        reviewView.mediaCollectionView.setData(items)
        updateReviewMediaHeight()
    }
    
    func updateReviewMediaHeight(){
        let contentHeight = reviewView.mediaCollectionView.cellSize.height
        if reviewMediaCollectionViewHeightAnchor.constant != contentHeight{
            reviewMediaCollectionViewHeightAnchor.constant = contentHeight
        }
    }
}

