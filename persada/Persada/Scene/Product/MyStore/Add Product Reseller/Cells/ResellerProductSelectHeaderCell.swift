//
//  AddProductResellerHeaderViewCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 09/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit

protocol ResellerProductSelectHeaderCellDelegate {
    func didSearch(_ text: String)
    func didChanged(_ text: String)
    func didClear()
}

class ResellerProductSelectHeaderCell: UICollectionViewCell {
    var delegate: ResellerProductSelectHeaderCellDelegate?
    
    lazy var iconSearch: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.iconSearchNavigation))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap(action: didSearch)
        return view
    }()
    
    lazy var iconClear: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: .get(.iconCommentClose))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.onTap(action: didClear)
        return view
    }()
    
    lazy var textField: UITextField = {
        let field = UITextField()
        field.placeholder = .get(.cariProduk)
        field.attributedPlaceholder = NSAttributedString(
            string: .get(.cariProduk),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.placeholder]
        )
        field.textColor = .contentGrey
        field.font = .Roboto(.regular, size: 12)
        field.returnKeyType = .done
        field.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        field.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        field.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .primaryActionTriggered)
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = 8
        self.withBorder(width: 1, color: .whiteSmoke)
        self.updateActionVisibility()
        
        let actionView = UIStackView(arrangedSubviews: [iconSearch, iconClear])
        actionView.axis = .horizontal
        actionView.distribution = .fill
        
        addSubViews([textField, actionView])
        actionView.anchor(right: rightAnchor, paddingRight: 12, width: 20, height: 20)
        textField.anchor(left: leftAnchor, right: actionView.leftAnchor, paddingLeft: 12, paddingRight: 12)
        actionView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isNilOrEmpty {
            delegate?.didChanged(text ?? "")
        }
        updateActionVisibility()
    }
    
    @objc func textFieldDidEnd(_ textField: UITextField) {
        textField.endEditing(true)
        didSearch()
    }
    
    private func didSearch(){
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isNilOrEmpty {
            delegate?.didSearch(text ?? "")
        }
        updateActionVisibility()
    }
    
    private func didClear(){
        textField.text = ""
        updateActionVisibility()
        delegate?.didClear()
    }
    
    private func updateActionVisibility(){
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        iconSearch.isHidden = !text.isNilOrEmpty
        iconClear.isHidden = text.isNilOrEmpty
    }
}
