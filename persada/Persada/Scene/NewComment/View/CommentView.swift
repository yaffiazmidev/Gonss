//
//  CommentView.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit

protocol CommentViewDelegate where Self: UIViewController {
	
	func like(id: String, status: String, index: Int)
	func subcomment(id: String, data: CommentHeaderCellViewModel)
	func pagination(total: Int)
	func dismiss()
	func refresh()
	func whenClickSubmit()
}

final class CommentView: UIView {
	
	weak var delegate: CommentViewDelegate?
	var keyboardHeightLayoutConstraint: NSLayoutConstraint?
	
	enum ViewTrait {
		static let margin: CGFloat = 16.0
	}
	
	var layout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		let width = UIScreen.main.bounds.size.width
		layout.estimatedItemSize = CGSize(width: width, height: 10)
		return layout
	}()
	
	lazy var commentTextField: CustomTextView = {
		let ctv = CustomTextView(backgroundColor: .white)
		ctv.placeholder = "Masukan Komentar"
		ctv.nameTextField.font = .Roboto(.medium)
		ctv.nameTextField.backgroundColor = .whiteSnow
		ctv.nameTextField.layer.cornerRadius = 8
		ctv.nameTextField.layer.borderColor = UIColor.whiteSmoke.cgColor
		ctv.nameTextField.layer.borderWidth = 1
		ctv.nameTextField.translatesAutoresizingMaskIntoConstraints = true
		ctv.nameTextField.sizeToFit()
		ctv.nameTextField.isScrollEnabled = false
		return ctv
	}()
	
	lazy var submitButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: String.get(.iconFeatherSend)), for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.addTarget(self, action: #selector(self.handleSubmitComment), for: .touchUpInside)
		
		return button
	}()
	
	lazy var emptyLabel : UILabel = {
		let label = UILabel(text: "Oppss...\nPostingan telah dihapus\noleh pemilik akun", font: .Roboto(.medium, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
		label.isHidden = true
		return label
	}()
	
	lazy var containerView: UIView = {
		let containerView = UIView()
		containerView.backgroundColor = .white
		
		containerView.addSubview(submitButton)
		submitButton.anchor(top: containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
		
		containerView.addSubview(self.commentTextField)
		self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
		
		let lineSeparator = UIView()
		lineSeparator.backgroundColor = UIColor.gainsboro
		containerView.addSubview(lineSeparator)
		lineSeparator.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
		
		return containerView
	}()
	
	lazy var collectionView: UICollectionView = {
		layout.scrollDirection = .vertical
		let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isUserInteractionEnabled = true
		collectionView.backgroundColor = .white
		collectionView.refreshControl = refreshControl
		collectionView.registerCustomCell(CommentCell.self)
		collectionView.register(CommentHeaderView.self, forSupplementaryViewOfKind: CommentView.className, withReuseIdentifier: CommentHeaderView.className)
		return collectionView
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refresh.isUserInteractionEnabled = false
        refresh.layer.zPosition = -1
		return refresh
	}()
	
	lazy var loading : UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView()
		indicator.color = .primary
		indicator.startAnimating()
		return indicator
	}()
	
	@objc private func handleRefresh() {
		self.delegate?.refresh()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .white
		
		addSubview(collectionView)
		addSubview(containerView)
		addSubview(emptyLabel)
		addSubview(loading)

		collectionView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: containerView.topAnchor, right: self.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
		
        containerView.anchor(top: nil, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
		
		keyboardHeightLayoutConstraint = containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -0)
		keyboardHeightLayoutConstraint?.isActive = true
		
		loading.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		loading.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		loading.anchor(width: 100, height: 100)
		emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
			emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
			emptyLabel.anchor(width: 250, height: 250)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleWhenTappedBackButton() {
		self.delegate?.dismiss()
	}
	
	@objc func handleSubmitComment() {
		self.delegate?.whenClickSubmit()
	}
	
	func hideView(){
		commentTextField.isHidden = true
		submitButton.isHidden = true
		collectionView.isHidden = true
		refreshControl.isHidden = true
		containerView.isHidden = true
		emptyLabel.isHidden = true
		loading.isHidden = false
	}
	
	func showView(){
		commentTextField.isHidden = false
		submitButton.isHidden = false
		collectionView.isHidden = false
		refreshControl.isHidden = false
		containerView.isHidden = false
		loading.isHidden = true
	}
	func showError(error: Error){
		commentTextField.isHidden = true
		submitButton.isHidden = true
		collectionView.isHidden = true
		refreshControl.isHidden = true
		containerView.isHidden = true
		loading.isHidden = true
		let err : String = "\(error)"
		if err.contains("400"){
			emptyLabel.isHidden = false
		} else {
			emptyLabel.isHidden = false
			refreshControl.isHidden = false
			emptyLabel.text = "Terjadi masalah! coba refresh untuk melanjutkan"
		}
	}
}

