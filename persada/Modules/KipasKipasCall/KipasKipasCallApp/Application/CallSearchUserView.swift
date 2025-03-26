//
//  CallSearchUserView.swift
//  KipasKipasCallApp
//
//  Created by Rahmat Trinanda Pramudya Amar on 23/12/23.
//

import UIKit
import KipasKipasShared

class CallSearchUserView: UIView {
    
    lazy var textField: KKBaseTextField = {
        let view = KKBaseTextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholderText = "Search User..."
        view.placeholderColor = .gainsboro
        view.placeholderLabel.font = .roboto(.regular, size: 12)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.insets.left = 12
        view.layer.borderColor = UIColor.gainsboro.cgColor
        view.layer.borderWidth = 1
        view.returnKeyType = .search
        
        return view
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = .primary
        view.isHidden = true
        return view
    }()
    
    lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .roboto(.medium, size: 12)
        label.text = "Search User Target"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(CallSearchUserCell.self, forCellReuseIdentifier: "CallSearchUserCell")
        view.separatorStyle = .singleLine
        view.isOpaque = true
        view.isHidden = true
        view.backgroundColor = .white
        view.estimatedRowHeight = 42
        view.rowHeight = UITableView.automaticDimension
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubviews([textField, loadingView, emptyLabel, tableView])
        textField.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: 12, paddingRight: 12, height: 32)
        loadingView.centerInSuperview(size: .init(width: 32, height: 32))
        emptyLabel.centerInSuperview()
        tableView.anchor(top: textField.bottomAnchor, left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: 12, paddingBottom: 12, paddingRight: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showLoading(_ show: Bool) {
        loadingView.isHidden = !show
        if show {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }
    
    func showEmpty(_ show: Bool, message: String? = nil) {
        if let message = message {
            emptyLabel.text = message
        }
        
        emptyLabel.isHidden = !show
    }
    
    func showTable(_ show: Bool) {
        tableView.isHidden = !show
    }
}
