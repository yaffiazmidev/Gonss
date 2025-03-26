//
//  DetailTransactionSalesView.swift
//  KipasKipas
//
//  Created by NOOR on 01/02/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit

protocol DetailTransactionSalesViewDelegate where Self: UIViewController {
	func hideDialog()
	func showDialog()
}

final class DetailTransactionSalesView: UIView {
	
	weak var delegate: DetailTransactionSalesViewDelegate?
    
    var handleTermAndCondition: ( (_ url: String) -> Void)?
	
	lazy var tableView: UITableView = {
		let table = UITableView(frame: .zero)
		table.translatesAutoresizingMaskIntoConstraints = false
		table.allowsMultipleSelection = false
		table.isMultipleTouchEnabled = false
		table.tableFooterView = UIView()
		table.backgroundColor = .white
		table.registerCustomCell(DetailTransactionHeaderItemCell.self)
		table.registerCustomCell(AreasItemCell.self)
		table.registerCustomCell(DetailItemUsernameTableViewCell.self)
		table.registerCustomCell(DetailLabelTappedItemCell.self)
		table.registerCustomCell(DetailTotalTableViewCell.self)
		table.registerCustomCell(DetailTransactionButtonItemCell.self)
		return table
	}()
	
	lazy var priceTermsView: UIView = {
		let view = UIView(frame: .zero)
		
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		[titleLabel, subtitleLabel].forEach {
			view.addSubview($0)
		}
		
		subtitleLabel.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 20, paddingBottom: 16, paddingRight: 20, height: 20)
        titleLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: subtitleLabel.topAnchor, right: view.rightAnchor, paddingTop: 16, paddingLeft: 20, paddingBottom: 8, paddingRight: 20)
		
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .secondaryLowTint
		return view
	}()
	
	let titleLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .grey, textAlignment: .left, numberOfLines: 0)
	let subtitleLabel = UILabel(font: .Roboto(.regular, size: 12), textColor: .secondary, textAlignment: .left, numberOfLines: 1)
	
	var priceTermsAnchorHeight: NSLayoutConstraint?
	var tableViewTopAnchor: NSLayoutConstraint?
	
	var awbNumberLabel = UILabel(font: .Roboto(.bold, size: 18), textColor: .black, textAlignment: .center, numberOfLines: 1)
	
	var barcodeImageView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isUserInteractionEnabled = true
		view.image = UIImage(named: .get(.LoginBG))
        view.contentMode = .scaleAspectFit
		return view
	}()
	
	lazy var backButton: UIButton = {
		let button = UIButton(image: UIImage(named: .get(.iconClose))! , tintColor: .secondary, target: self, action: #selector(handleBack(_:)))
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	var barcodeView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.masksToBounds = false
		view.layer.cornerRadius = 8
		view.isHidden = true
		return view
	}()
	
	var viewBackground: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .black
		view.alpha = 0.4
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGestureBack(sender:)))
		tapGesture.numberOfTapsRequired = 1
		tapGesture.isEnabled = true
		view.addGestureRecognizer(tapGesture)
		view.isUserInteractionEnabled = true
		view.isHidden = true
		return view
	}()
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		return refresh
	}()
    
    lazy  var loadingIndicator: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.style = .large
        loading.color = .primaryPink
        loading.startAnimating()
        return loading
    }()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(priceTermsView)
		addSubview(tableView)
		addSubview(viewBackground)
		addSubview(barcodeView)
        addSubview(loadingIndicator)
		
		let tableHeaderHeight = CGFloat(40)
		let tableWidth = self.tableView.bounds.size.width
		let tableFrame = CGRect(x: 0, y: 0, width: tableWidth , height: tableHeaderHeight)
		tableView.tableHeaderView = UIView(frame: tableFrame)// set the content insets top value
		tableView.contentInset = UIEdgeInsets(top: -tableHeaderHeight, left: 0, bottom: 0, right: 0)
		tableView.separatorStyle = .none
		
		setupBarcodeView()
		
		priceTermsView.anchor(top: safeAreaLayoutGuide.topAnchor, left: safeAreaLayoutGuide.leftAnchor, right: safeAreaLayoutGuide.rightAnchor)
		
		tableView.anchor(left: safeAreaLayoutGuide.leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: safeAreaLayoutGuide.rightAnchor)
		tableView.refreshControl = refreshControl
        loadingIndicator.centerXTo(centerXAnchor)
        loadingIndicator.centerYTo(centerYAnchor)
	}
	
	private func setupBarcodeView() {
		barcodeView.centerXTo(centerXAnchor)
		barcodeView.centerYTo(centerYAnchor)
		let widthScreen = UIScreen.main.bounds.width
		barcodeView.anchor(width: widthScreen - 60, height: widthScreen - 60)
		viewBackground.fillSuperviewSafeAreaLayoutGuide()
		
		barcodeView.addSubview(barcodeImageView)
		barcodeView.addSubview(backButton)
		barcodeView.addSubview(awbNumberLabel)
		
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
		
		backButton.anchor(top: barcodeView.topAnchor, right: barcodeView.rightAnchor, paddingTop: 16, paddingRight: 16, width: 30, height: 30)
		awbNumberLabel.anchor(left: barcodeView.leftAnchor, right: barcodeView.rightAnchor, paddingLeft: 16, paddingRight: 16)
        barcodeImageView.anchor(left: barcodeView.leftAnchor, bottom: awbNumberLabel.topAnchor, right: barcodeView.rightAnchor, paddingLeft: 16, paddingBottom: 8, paddingRight: 16, height: widthScreen * 0.4)
        barcodeImageView.centerYAnchor.constraint(equalTo: barcodeView.centerYAnchor).isActive = true
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func showHiddenPriceTerms(isHidden: Bool, _ title: String = "", _ subtitle: String = "") {
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: subtitle, attributes: underlineAttribute)
		if !isHidden {
			
			priceTermsAnchorHeight = priceTermsView.heightAnchor.constraint(equalToConstant: 0)
			priceTermsAnchorHeight?.isActive = false
			priceTermsView.isHidden = true
            titleLabel.text = title
			subtitleLabel.attributedText = underlineAttributedString
			
			tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8)
			tableViewTopAnchor?.isActive = true
		} else {
			priceTermsAnchorHeight = priceTermsView.heightAnchor.constraint(equalToConstant: 104)
			priceTermsAnchorHeight?.isActive = true
			priceTermsView.isHidden = false
			titleLabel.text = title
            subtitleLabel.attributedText = underlineAttributedString
            let priceGesture = UITapGestureRecognizer(target: self, action: #selector(handleConditionPricing))
            subtitleLabel.addGestureRecognizer(priceGesture)
            subtitleLabel.isUserInteractionEnabled = true
			
			tableViewTopAnchor = tableView.topAnchor.constraint(equalTo: priceTermsView.bottomAnchor, constant: 8)
			tableViewTopAnchor?.isActive = true
		}
	}
	
	func setup(_ imageData: Data, _ awbNumber: String) {
		barcodeImageView.image = UIImage(data: imageData)
		awbNumberLabel.text = awbNumber
	}
	
	@objc func handleShowBarcode(_ sender: UIButton) {
		self.delegate?.hideDialog()
	}
	
	@objc func handleGestureBack(sender: UITapGestureRecognizer) {
		self.delegate?.hideDialog()
	}
	
	@objc func handleBack(_ sender: UIButton) {
		self.delegate?.hideDialog()
	}
    
    @objc
    func handleConditionPricing() {
        handleTermAndCondition?(.get(.kipasKipasTermsConditionsUrl))
    }
}

