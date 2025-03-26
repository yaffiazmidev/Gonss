//
//  VerifyIdentityCountryOrRegionTVC.swift
//  KipasKipasVerificationIdentityiOS
//
//  Created by DENAZMI on 31/05/24.
//

import UIKit

class VerifyIdentityCountryOrRegionTVC: UITableViewCell {
    
    let countryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupComponents()
    }
    
    private func setupComponents() {
        selectionStyle = .none
        contentView.addSubview(countryLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            countryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            countryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            countryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    func configure(with country: String) {
        countryLabel.text = country
    }
}
