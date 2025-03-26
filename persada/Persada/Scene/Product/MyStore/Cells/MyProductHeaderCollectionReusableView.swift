//
//  MyProductHeaderCollectionReusableView.swift
//  KipasKipas
//
//  Created by Rahmat Trinanda Pramudya Amar on 07/09/22.
//  Copyright © 2022 Koanba. All rights reserved.
//

import UIKit

protocol MyProductHeaderDelegate: AnyObject {
    func didViewTransactionHistory()
    func didWithdrawBalance()
    func didMessageAddress()
    func didMessageEmail()
    func didSelectProductType(_ type: ProductType)
}


class MyProductHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: MyProductHeaderDelegate?
    
    var balance: MyStoreBalance? {
        didSet { collectionView.reloadSections(IndexSet(integer: 0)) }
    }
    
    var addressSection: Int = 0 {
        didSet { collectionView.reloadSections(IndexSet(integer: 1)) }
    }
    
    var emailSection: Int = 0 {
        didSet { collectionView.reloadSections(IndexSet(integer: 2)) }
    }
    
    var productType: ProductType = .all {
        didSet { collectionView.reloadSections(IndexSet(integer: 4)) }
    }
    
    private enum MyHeaderSection: Int, CaseIterable {
        case balance        = 0
        case addressInfo    = 1
        case emailInfo      = 2
        case productHeader  = 3
        case productType    = 4
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
        backgroundColor = .white
        collectionView.backgroundColor = .white
    }
    
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerXibCell(MyProductHeaderCollectionViewCell.self)
        collectionView.registerXibCell(MyProductInfoCollectionViewCell.self)
        collectionView.register(ProductCollectionViewCellHeader.self, forCellWithReuseIdentifier: "ProductCollectionViewCellHeader")
        collectionView.registerCustomCell(MyProductTypeCell.self)
    }
}


extension MyProductHeaderCollectionReusableView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { MyHeaderSection.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = MyHeaderSection(rawValue: section) else { return 0  }
        switch section {
        case .balance: return 1
        case .addressInfo: return addressSection
        case .emailInfo: return emailSection
        case .productHeader: return 1
        case .productType: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = MyHeaderSection(rawValue: indexPath.section) else { return UICollectionViewCell()  }
        
        switch section {
        case .balance:
            let cell = collectionView.dequeueReusableCell(MyProductHeaderCollectionViewCell.self, for: indexPath)
            cell.configure(balance: self.balance)
            cell.viewTransactionHistoryButton.onTap { [weak self] in self?.delegate?.didViewTransactionHistory() }
            cell.withdrawBalenceButton.onTap { [weak self] in self?.delegate?.didWithdrawBalance() }
            return cell
        case .addressInfo:
            let cell = collectionView.dequeueReusableCell(MyProductInfoCollectionViewCell.self, for: indexPath)
            cell.setup(title: "Tambahkan alamat pengiriman dari toko kamu untuk mulai jualan di KipasKipas",
                       actionBntTitle: "Alamat Toko")
            cell.messageButton.onTap { [weak self] in self?.delegate?.didMessageAddress() }
            return cell
        case .emailInfo:
            let cell = collectionView.dequeueReusableCell(MyProductInfoCollectionViewCell.self, for: indexPath)
            cell.setup(title: "Masukan satu alamat email yang akan kamu gunakan sebagai email utama toko",
                       actionBntTitle: "Input Email")
            cell.messageButton.onTap { [weak self] in self?.delegate?.didMessageEmail() }
            return cell
        case .productHeader:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCellHeader", for: indexPath) as! ProductCollectionViewCellHeader
        case .productType:
            let cell = collectionView.dequeueReusableCustomCell(with: MyProductTypeCell.self, indexPath: indexPath)
            cell.type = productType
            cell.didButtonSelected = { type in
                self.delegate?.didSelectProductType(type)
            }
            return cell
        }
    }
}

extension MyProductHeaderCollectionReusableView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = MyHeaderSection(rawValue: indexPath.section) else { return collectionView.frame.size }
        let width = collectionView.frame.size.width
        switch section {
        case .balance: return CGSize(width: width, height: 247)
        case .addressInfo: return CGSize(width: width, height: 106)
        case .emailInfo: return CGSize(width: width, height: 106)
        case .productHeader: return CGSize(width: width, height: 42)
        case .productType: return CGSize(width: width, height: 32)
        }
    }
}
