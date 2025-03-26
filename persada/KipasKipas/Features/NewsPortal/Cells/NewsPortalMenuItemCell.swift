//
//  NewsPortalMenuItemCell.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 10/01/24.
//  Copyright © 2024 Koanba. All rights reserved.
//

import UIKit
import Kingfisher

enum NewsPortalMenuItemCellAction {
    case none
    case add
    case remove
}

protocol NewsPortalMenuItemCellDelegate: AnyObject {
    func didRemove(_ item: NewsPortalItem)
    func didAdd(_ item: NewsPortalItem)
    func didSelect(_ item: NewsPortalItem)
}

class NewsPortalMenuItemCell: UICollectionViewCell {
    
    weak var delegate: NewsPortalMenuItemCellDelegate?
    
    private let actionSize: CGFloat = 24
    private let imageSize: CGFloat = 42
    private var currentAction: NewsPortalMenuItemCellAction = .none
    private let TAG_MAINVIEW = 11
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .Roboto(.regular, size: 12)
        label.textColor = .contentGrey
        label.textAlignment = .center
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: .get(.empty))
        
        return view
    }()
    
    private lazy var placeholderView: UIView = {
        let dashed = DashedBorderView(dashedLineColor: UIColor.grey.cgColor, dashedLinePattern: [4, 4], dashedLineWidth: 1, cornerRadius: imageSize / 2)
        dashed.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dashed)
        dashed.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: actionSize / 2)
        
        return view
    }()
    
    private lazy var actionRemoveView: UIView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: .get(.iconRemoveCircleRedBorderWhite))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var actionAddView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: .get(.iconAddCircleGreenBorderWhite))
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var actionView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [actionRemoveView, actionAddView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.alignment = .center
        
        actionRemoveView.anchor(width: actionSize, height: actionSize)
        actionAddView.anchor(width: actionSize, height: actionSize)
        
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubViews([imageView, actionView])
        
        actionView.anchor(top: view.topAnchor)
        actionView.centerXTo(view.centerXAnchor)
        imageView.anchor(top: actionView.centerYAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, width: imageSize, height: imageSize)
        
        return view
    }()
    
    private lazy var topSpacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [topSpacingView, placeholderView, headerView, nameLabel])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 6
        view.tag = TAG_MAINVIEW
        
        topSpacingView.anchor(height: 10)
        placeholderView.anchor(width: imageSize, height: imageSize + (actionSize / 2))
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear // memory consume 1,8 M
//        addSubview(mainView)
//        mainView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        imageView.image = nil
        mainView.removeFromSuperview()
    }

    func configure(with data: NewsPortalItem?, action: NewsPortalMenuItemCellAction, useTopSpacing: Bool = false) {
        if ( viewWithTag(TAG_MAINVIEW) == nil ) {
            addSubview(mainView)
            mainView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingRight: 8)
        }

        placeholderView.isHidden = data != nil
        headerView.isHidden = data == nil
        nameLabel.isHidden = data == nil
        
        guard let data = data else { return }
        
        nameLabel.text = data.name
        //imageView.kf.setImage(with: URL(string: data.image))
        imageView.loadImage(at: data.image, .w100)
        topSpacingView.isHidden = !useTopSpacing
        
        currentAction = action
        setupAction(action)
        
//        nameLabel.onTap { self.delegate?.didSelect(data) }
//        imageView.onTap { self.delegate?.didSelect(data) }
//        actionAddView.onTap { self.delegate?.didAdd(data) }
//        actionRemoveView.onTap { self.delegate?.didRemove(data) }
        
        nameLabel.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSelect(data)
        }
        
        imageView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSelect(data)
        }

        actionAddView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didAdd(data)
        }

        actionRemoveView.onTap { [weak self] in
            guard let self = self else { return }
            self.delegate?.didRemove(data)
        }

    }
    
    override func dragStateDidChange(_ dragState: UICollectionViewCell.DragState) {
        switch dragState {
        case .dragging:
            backgroundColor = .clear
            setupAction(currentAction)
            actionView.isHidden = false
            topSpacingView.isHidden = true
        case .none:
            backgroundColor = .clear
            setupAction(currentAction)
            actionView.isHidden = false
            topSpacingView.isHidden = true
        case .lifting:
            backgroundColor = .white
            setupAction(.none)
            actionView.isHidden = true
            topSpacingView.isHidden = false
        default: break
        }
    }
    
    private func setupAction(_ action: NewsPortalMenuItemCellAction) {
        switch action {
        case .none:
            actionAddView.isHidden = true
            actionRemoveView.isHidden = true
        case .add:
            actionAddView.isHidden = false
            actionRemoveView.isHidden = true
        case .remove:
            actionAddView.isHidden = true
            actionRemoveView.isHidden = false
        }
    }
}
