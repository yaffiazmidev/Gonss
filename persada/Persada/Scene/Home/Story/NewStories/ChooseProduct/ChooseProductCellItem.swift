//
//  ChooseProductCellItem.swift
//  Persada
//
//  Created by movan on 20/07/20.
//  Copyright © 2020 Muhammad Noor. All rights reserved.
//

import UIKit
import Combine

final class ChooseProductCellItem: UITableViewCell {
    static let identifier = "ChooseProductCellItem"
    
    var viewModel: ChooseProductCellViewModel! {
        didSet {
            setUpViewModel()
        }
    }
    
    lazy var playerNameLabel = UILabel()
    
    lazy var teamLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubiews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubiews() {
        let subviews = [playerNameLabel, teamLabel]
        
        subviews.forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setUpConstraints() {
        let playerNameLabelConstraints = [
            playerNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0),
            playerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10.0),
            playerNameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0)
        ]
        
        let teamLabelConstraints = [
            teamLabel.centerYAnchor.constraint(equalTo: playerNameLabel.centerYAnchor),
            teamLabel.leadingAnchor.constraint(equalTo: playerNameLabel.trailingAnchor, constant: 10.0),
            teamLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.0),
            teamLabel.heightAnchor.constraint(equalTo: playerNameLabel.heightAnchor)
        ]
        
        [playerNameLabelConstraints, teamLabelConstraints].forEach(NSLayoutConstraint.activate(_:))
    }
    
    private func setUpViewModel() {
		playerNameLabel.text = viewModel.nameProduct
        teamLabel.text = viewModel.price
        
        // accessing PropertyWrapper does not work here
        //        viewModel.$playerName.assign(to: \.text, on: playerNameLabel)
        //        viewModel.$team.assign(to: \.text, on: teamLabel)
    }
}
