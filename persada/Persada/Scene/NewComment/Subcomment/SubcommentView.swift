//
//  SubcommentView.swift
//  Persada
//
//  Created by NOOR on 25/06/20.
//  Copyright (c) 2020 Muhammad Noor. All rights reserved.

import UIKit
import RxSwift
import RxCocoa

protocol SubcommentViewDelegate where Self: UIViewController {

	func pagination(total: Int)
	func dismiss()
	func refresh()
	func whenSubmitClicked()
}

final class SubcommentView: UIView {
	
    private let disposeBag = DisposeBag()
	weak var delegate: SubcommentViewDelegate?
	var keyboardHeightLayoutConstraint: NSLayoutConstraint?
	
	enum ViewTrait {
		static let leftMargin: CGFloat = 10.0
	}
	
	var items : [Subcomment]? = []
	var headerItems: CommentHeaderCellViewModel?

	var layout: UICollectionViewFlowLayout = {
		let layout = UICollectionViewFlowLayout()
		let width = UIScreen.main.bounds.size.width
		layout.estimatedItemSize = CGSize(width: width, height: 10)
		return layout
	}()

	lazy var commentTextField: CustomTextView = {
        let ctv = CustomTextView(backgroundColor: .white)
        ctv.nameTextField.font = .Roboto(.regular, size: 12)
		ctv.nameTextField.backgroundColor = .white
		ctv.nameTextField.layer.cornerRadius = 5
        ctv.nameTextField.layer.borderColor = UIColor(displayP3Red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        ctv.nameTextField.layer.borderWidth = 0.5
		ctv.nameTextField.translatesAutoresizingMaskIntoConstraints = true
		ctv.nameTextField.sizeToFit()
		ctv.nameTextField.isScrollEnabled = false
        ctv.nameTextField.textContainerInset = UIEdgeInsets(horizontal: 3, vertical: 0)
		return ctv
	}()

	lazy var submitButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(named: String.get(.iconFeatherSendGray)), for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.addTarget(self, action: #selector(handleSubmitComment), for: .touchUpInside)

		return button
	}()

    lazy var containerView: UIView = {
        let containerView = UIView()
        let lineSeparator = UIView()
        containerView.backgroundColor = .white

        containerView.addSubview(submitButton)
        containerView.addSubview(commentTextField)
        containerView.addSubview(lineSeparator)
        
        submitButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 33, height: 33)
        submitButton.centerYAnchor.constraint(equalTo: commentTextField.centerYAnchor).isActive = true

        self.commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)

        lineSeparator.backgroundColor = UIColor.placeholder
        lineSeparator.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        lineSeparator.isHidden = true

        return containerView
    }()
    
	lazy var collectionView: UICollectionView = {
		layout.scrollDirection = .vertical
		let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .white
		view.registerCustomCell(SubCommentCell.self)
		view.registerCustomReusableHeaderView(SubcommentHeaderView.self)
		return view
	}()
	
	lazy var refreshControl: UIRefreshControl = {
		let refresh = UIRefreshControl()
		refresh.tintColor = .primary
		refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		return refresh
	}()
	
	@objc private func handleRefresh() {
		self.delegate?.refresh()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		isUserInteractionEnabled = true
		backgroundColor = .white

        addSubview(collectionView)
        addSubview(containerView)
        collectionView.refreshControl = refreshControl
        collectionView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: containerView.topAnchor, right: self.rightAnchor, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)

        containerView.anchor(top: nil, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, height: 46)

        keyboardHeightLayoutConstraint = containerView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -11)
        keyboardHeightLayoutConstraint?.isActive = true
        
        commentTextField.nameTextField.rx.didChange
            .bind {
                self.commentTextField.nameTextField.centerVerticalText()
            }.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@objc func handleWhenTappedBackButton() {
		self.delegate?.dismiss()
	}

	@objc func handleSubmitComment() {
		self.delegate?.whenSubmitClicked()
	}
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
	
}
