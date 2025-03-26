//
//  ReviewAddMediaView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 31/10/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared

class ReviewAddMedia {
    let item: KKMediaItem
    var media: ReviewMedia?
    
    init(item: KKMediaItem, media: ReviewMedia? = nil) {
        self.item = item
        self.media = media
    }
}

class ReviewAddMediaView: UIView{
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var handleAddMedia: (() -> Void)?
    var handleRemoveMedia: ((Int) -> Void)?
    var handleHeightUpdated: ((CGFloat) -> Void)?
    var data: [ReviewAddMedia] = []
    
    lazy var emptyView: UIView = {
        let view = DashedBorderView(dashedLineColor: UIColor.whiteSmoke.cgColor, dashedLineWidth: 1.0)
        
        let icon = UIImageView(image: UIImage(named: .get(.iconCamera)))
        let caption = UILabel(text: "Tambahkan foto/video produk yang kamu terima", font: .Roboto(.regular, size: 12), textColor: .placeholder, textAlignment: .center, numberOfLines: 0)
        
        view.addSubview(icon)
        view.addSubview(caption)
        icon.anchor(top: view.topAnchor, paddingTop: 8, paddingLeft: 12, paddingRight: 12, width: 24, height: 24)
        caption.anchor(top: icon.bottomAnchor, bottom: view.bottomAnchor, paddingTop: 8, paddingLeft: 12, paddingBottom: 8, paddingRight: 12)
        icon.centerXTo(view.centerXAnchor)
        caption.centerXTo(view.centerXAnchor)
        
        view.onTap { [weak self] in
            self?.handleAddMedia?()
        }
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    static func loadViewFromNib() -> ReviewAddMediaView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "ReviewAddMediaView", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! ReviewAddMediaView
    }
    
    private func setupView(){
        stackView.addArrangedSubview(emptyView)
        emptyView.fillSuperview()
        collectionView.fillSuperview()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.registerXibCell(ReviewAddMediaCollectionViewCell.self)
        layoutIfNeeded()
    }
    
    func refreshItem(at index: Int){
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
        updateView()
    }
    
    func removeItem(at index: Int){
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.deleteItems(at: [indexPath])
        updateView()
    }
    
    private func updateView(){
        emptyView.isHidden = !data.isEmpty
        collectionView.isHidden = data.isEmpty
    }
}

extension ReviewAddMediaView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width - 32) / 5
        handleHeightUpdated?(size)
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension ReviewAddMediaView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ReviewAddMediaCollectionViewCell.self, for: indexPath)
        let index = indexPath.row
        if index < data.count {
            cell.setupView(data[index])
            cell.closeView.onTap { [weak self] in
                self?.handleRemoveMedia?(indexPath.row)
            }
        }else{
            cell.addView.onTap { [weak self] in
                self?.handleAddMedia?()
            }
        }
        return cell
    }
}
