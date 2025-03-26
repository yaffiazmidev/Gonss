//
//  DonationEmptyView.swift
//  FeedCleeps
//
//  Created by Rahmat Trinanda Pramudya Amar on 13/05/24.
//

import UIKit
import KipasKipasShared

protocol DonationEmptyViewDelegate: AnyObject {
    func didRefresh()
    func didChangeFilter()
}

class DonationEmptyView: UIView {
    
    weak var delegate: DonationEmptyViewDelegate?
    
    var isFilterActive: Bool = false {
        didSet {
            updateView()
        }
    }
    
    lazy var emptyDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = .Roboto(.medium, size: 14)
        label.text = "Maaf, belum ada donasi tersedia. Kamu bisa periksa kembali nanti."
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var emptyDataButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(hexString: "#F9F9F9")
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.init(hexString: "#EEEEEE").cgColor
        button.setTitle("Muat Ulang")
        button.setTitleColor(.primary, for: .normal)
        button.titleLabel?.font = .Roboto(.bold, size: 14)
        
        return button
    }()
    
    lazy var emptyDataView: UIView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = .imageLockBox
        image.contentMode = .scaleAspectFit
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        view.addSubviews([image, emptyDataLabel, emptyDataButton])
        
        image.anchors.width.equal(92)
        image.anchors.centerX.equal(view.anchors.centerX)
        image.anchors.top.equal(view.anchors.top)
        
        emptyDataLabel.anchors.leading.equal(view.anchors.leading, constant: 16)
        emptyDataLabel.anchors.trailing.equal(view.anchors.trailing, constant: -16)
        emptyDataLabel.anchors.top.equal(image.anchors.bottom, constant: 16)
        
        emptyDataButton.anchors.width.equal(124)
        emptyDataButton.anchors.height.equal(40)
        emptyDataButton.anchors.centerX.equal(view.anchors.centerX)
        emptyDataButton.anchors.top.equal(emptyDataLabel.anchors.bottom, constant: 24)
        emptyDataButton.anchors.bottom.equal(view.anchors.bottom)
        
        return view
    }()
    
    lazy var emptyFilterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = .Roboto(.medium, size: 14)
        label.text = "Tidak ada donasi yang cocok dengan filter, silahkan ubah filter !"
        label.numberOfLines = 0
        return label
    }()
    
    lazy var emptyFilterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .primary
        button.layer.cornerRadius = 4
        button.setTitle(" Filter")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .Roboto(.bold, size: 14)
        button.setImage(.iconList)
        button.centerTextAndImage(spacing: 4)
        
        return button
    }()
    
    lazy var emptyFilterView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .white.withAlphaComponent(0.2)
        view.isHidden = true
        
        view.addSubviews([emptyFilterLabel, emptyFilterButton])
        
        emptyFilterLabel.anchors.leading.equal(view.anchors.leading, constant: 16)
        emptyFilterLabel.anchors.trailing.equal(view.anchors.trailing, constant: -16)
        emptyFilterLabel.anchors.top.equal(view.anchors.top, constant: 16)
    
        emptyFilterButton.anchors.width.equal(84)
        emptyFilterButton.anchors.height.equal(32)
        emptyFilterButton.anchors.centerX.equal(view.anchors.centerX)
        emptyFilterButton.anchors.top.equal(emptyFilterLabel.anchors.bottom, constant: 16)
        emptyFilterButton.anchors.bottom.equal(view.anchors.bottom, constant: -20)
        
        return view
    }()
    
    // MARK: Function
    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }
}

// MARK: - UI Controll
private extension DonationEmptyView {
    func configUI() {
        backgroundColor = .init(hexString: "#10012F")
        
        addSubviews([emptyDataView, emptyFilterView])
        
        emptyDataView.anchors.leading.equal(anchors.leading, constant: 48)
        emptyDataView.anchors.trailing.equal(anchors.trailing, constant: -48)
        emptyDataView.anchors.centerY.equal(anchors.centerY)
        
        emptyFilterView.anchors.leading.equal(anchors.leading, constant: 48)
        emptyFilterView.anchors.trailing.equal(anchors.trailing, constant: -48)
        emptyFilterView.anchors.centerY.equal(anchors.centerY)
        
        setupOnTap()
        updateView()
    }
    
    func setupOnTap() {
        emptyDataButton.onTap { [weak self] in
            self?.delegate?.didRefresh()
        }
        
        emptyFilterButton.onTap { [weak self] in
            self?.delegate?.didChangeFilter()
        }
    }
    
    func updateView() {
        emptyDataView.isHidden = isFilterActive
        emptyFilterView.isHidden = !isFilterActive
    }
}

fileprivate extension UIButton {
    func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
           imageEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
           titleEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
           contentEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: -insetAmount)
        } else {
           imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
           titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
           contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}
