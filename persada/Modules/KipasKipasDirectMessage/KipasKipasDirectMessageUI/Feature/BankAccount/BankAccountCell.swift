//
//  BankAccountCell.swift
//  KipasKipasDirectMessageUI
//
//  Created by Muhammad Noor on 05/09/23.
//

import UIKit
import KipasKipasDirectMessage

class BankAccountCell: UITableViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "iconRadioButtonUnchecked")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = 4
        view.addArrangedSubview(bankNameLabel)
        view.addArrangedSubview(norekStackView)
        return view
    }()

    private lazy var norekStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = 7
        view.addArrangedSubview(usernameLabel)
        view.addArrangedSubview(norekLabel)
        return view
    }()

    private lazy var separatorView: UIView = {
        let view: UIView = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()

    private let bankNameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .Roboto(.bold, size: 12)
        
        return label
    }()
    
    private let norekLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = .Roboto(.medium, size: 12)
        
        return label
    }()
    
    private let usernameLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .Roboto(.medium, size: 12)
        
        return label
    }()
    private let checked = UIImage(named: "iconRadioButtonChecked")
    private let unchecked = UIImage(named: "iconRadioButtonUncheck")
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
       
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 12).isActive = true
        stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 12).isActive = true
        
        addSubview(iconImageView)
        iconImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 12).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor).isActive = true
        
        addSubview(separatorView)
        separatorView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        separatorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        separatorView.bottomAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    func setup(value: Banks) {
        usernameLabel.text = value.accountName ?? ""
        norekLabel.text = value.accountNumber ?? ""
        bankNameLabel.text = value.bank?.name ?? ""
    }
    
    public func isSelected(_ selected: Bool) {
        let image = selected ? checked : unchecked
        iconImageView.image = image
    }
}
