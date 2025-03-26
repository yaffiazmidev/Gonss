//
//  NotificationBannedView.swift
//  KipasKipas
//
//  Created by koanba on 08/07/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationBannedView: UIView {
    
    private let disposeBag = DisposeBag()
    private let mediasList = BehaviorRelay<[Medias]>(value: [])

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var viewReason: UIView!
    @IBOutlet weak var labelTitleReason: UILabel!
    @IBOutlet weak var labelReason: UILabel!
    @IBOutlet weak var labelItemName: UILabel!
    @IBOutlet weak var labelItemPrice: UILabel!
    @IBOutlet weak var labelTitleCategory: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelTitleDimension: UILabel!
    @IBOutlet weak var labelDimension: UILabel!
    @IBOutlet weak var labelTitleWeight: UILabel!
    @IBOutlet weak var labelWeight: UILabel!
    @IBOutlet weak var labelTitleDescription: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var collectionMedia: UICollectionView!
    @IBOutlet weak var collectionMediaHeightConstraint: NSLayoutConstraint!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    static func loadViewFromNib() -> NotificationBannedView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "NotificationBannedView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! NotificationBannedView
    }
    
    func initView() {
        viewReason.backgroundColor = .primaryLowTint
        
        labelTitleReason.font = .Roboto(.regular, size: 14)
        labelTitleReason.textColor = .grey
        
        labelReason.font = .Roboto(.bold, size: 14)
        labelReason.textColor = .black
        
        labelItemName.font = .Roboto(.bold, size: 16)
        labelItemName.textColor = .contentGrey
        
        labelItemPrice.font = .Roboto(.medium, size: 14)
        labelItemPrice.textColor = .grey
        
        labelTitleCategory.font = .Roboto(.bold, size: 14)
        labelTitleCategory.textColor = .contentGrey
        
        labelCategory.font = .Roboto(.medium, size: 16)
        labelCategory.textColor = .grey
        
        labelTitleDimension.font = .Roboto(.bold, size: 14)
        labelTitleDimension.textColor = .contentGrey
        
        labelDimension.font = .Roboto(.medium, size: 16)
        labelDimension.textColor = .grey
        
        labelTitleWeight.font = .Roboto(.bold, size: 14)
        labelTitleWeight.textColor = .contentGrey
        
        labelWeight.font = .Roboto(.medium, size: 16)
        labelWeight.textColor = .grey
        
        labelTitleDescription.font = .Roboto(.bold, size: 14)
        labelTitleDescription.textColor = .contentGrey
        
        labelDescription.font = .Roboto(.medium, size: 14)
        labelDescription.textColor = .grey
        
        collectionMedia.backgroundColor = .clear
        collectionMedia.register(UINib(nibName: BannedProductCell.self.className, bundle: nil), forCellWithReuseIdentifier: BannedProductCell.self.className)
        
        setupObservers()
    }
    
    func setupObservers() {
        collectionMedia.rx.setDelegate(self).disposed(by: disposeBag)
        self.mediasList.bind(to: collectionMedia.rx.items(cellIdentifier: BannedProductCell.self.className, cellType: BannedProductCell.self)) { row, medias, cell in
            cell.setup(medias: medias)
        }.disposed(by: disposeBag)
    }
    
    func setupView(product: Product) {
        labelReason.text = product.reasonBanned
        labelItemName.text = product.name
        labelItemPrice.text = product.price?.toMoney()
        labelCategory.text = product.accountId
        labelWeight.text = "\(product.measurement?.weight ?? 0) kg"
        labelDescription.text = product.postProductDescription
        
        let length = product.measurement?.length ?? 0
        let widht = product.measurement?.width ?? 0
        let height = product.measurement?.height ?? 0
        labelDimension.text = "\(length) cm x \(widht) cm x \(height) cm"
    
        self.mediasList.accept(product.medias ?? [])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.update(contentView: contentView, height: labelDescription.frame.maxY + safeAreaInsets.bottom + 30)
    }
    
}

extension NotificationBannedView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width - 3 * 8) / 4
        let line = CGFloat(indexPath.item / 4)
        self.collectionMediaHeightConstraint.constant = ((line + 1) * size) + (line * 8)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}
