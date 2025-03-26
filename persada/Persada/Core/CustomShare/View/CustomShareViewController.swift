//
//  CustomShareView.swift
//  KipasKipas
//
//  Created by PT.Koanba on 22/10/21.
//  Copyright © 2021 Koanba. All rights reserved.
//

import Foundation
import UIKit
import FeedCleeps
import Photos

enum CustomShareItemType {
    case content
    case donation
    case shop
    case live
    case story
}

struct CustomShareItem {
    let id: String?
    let message: String
    let type: CustomShareItemType
    let assetUrl: String
    let accountId: String
    let name: String?
    let price: Double?
    let username: String?
    
    init(id: String? = nil, message: String, type: CustomShareItemType, assetUrl: String, accountId: String, name: String? = nil, price: Double? = nil, username: String? = nil) {
        self.id = id
        self.message = message
        self.type = type
        self.assetUrl = assetUrl
        self.accountId = accountId
        self.name = name
        self.price = price
        self.username = username
    }
}

class CustomShareViewController : UIViewController, AlertDisplayer, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var topViewForDismissGesture: UIView!
    @IBOutlet weak var collectionViewSocmedShareList: UICollectionView!
    @IBOutlet weak var collectionViewOthersShareList: UICollectionView!
    @IBOutlet weak var buttonCancelShare: UIButton!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    private var viewModel : CustomShareViewModel!
    private let item: CustomShareItem!
    
    var onClickReport: (() -> Void)?
    var onViewWillAppear: (() -> Void)?
    
    init(item: CustomShareItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareModel()
        registerView()
        
        self.viewModel.bindSocmedShareViewModelToController = {
            self.collectionViewSocmedShareList.reloadData()
        }
        
        self.viewModel.bindLocalShareViewModelToController = {
            self.collectionViewOthersShareList.reloadData()
        }
        
        self.viewModel.bindLoading = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingView.startAnimating()
                    return
                }
                self?.loadingView.stopAnimating()
            }
            return
        }
        
        self.viewModel.bindError = { [weak self] error in
            self?.displayAlert(with: .get(.error), message: error, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        }
        
        registeTapDismissGesture()
    }
    
    private func registeTapDismissGesture() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        
        gestureRecognizer.cancelsTouchesInView = false
        
        topViewForDismissGesture.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadingView.stopAnimating()
        onViewWillAppear?()
    }
    
    @IBAction func cancelAndDismiss(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    func prepareModel(){
        viewModel = CustomShareViewModel(controller: self, item: self.item)
        if viewModel.socmedShare.isEmpty {
            self.collectionViewSocmedShareList.isHidden = true
        }
    }
    
    func registerView(){
        collectionViewSocmedShareList.register(UINib(nibName: "CustomShareCellView", bundle: nil), forCellWithReuseIdentifier:  "SocmedShareCell")
        collectionViewOthersShareList.register(UINib(nibName: "CustomShareCellView", bundle: nil), forCellWithReuseIdentifier:  "LocalShareCell")
        collectionViewSocmedShareList.dataSource = self
        collectionViewOthersShareList.dataSource = self
        collectionViewSocmedShareList.delegate = self
        collectionViewOthersShareList.delegate = self
        collectionViewSocmedShareList.backgroundColor = .white
        collectionViewSocmedShareList.backgroundView?.backgroundColor = .white
        collectionViewOthersShareList.backgroundColor = .white
        collectionViewOthersShareList.backgroundView?.backgroundColor = .white
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionViewSocmedShareList {
            return viewModel.socmedShare.count
        }
        return viewModel.localShare.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionViewSocmedShareList {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SocmedShareCell", for: indexPath) as! CustomShareCellView
            cell.data = viewModel.socmedShare[indexPath.row]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalShareCell", for: indexPath) as! CustomShareCellView
        cell.data = viewModel.localShare[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = collectionView == collectionViewSocmedShareList ? viewModel.socmedShare[indexPath.row] : viewModel.localShare[indexPath.row]
        
        if item.type == .report {
            onClickReport?()
        }
        
        self.viewModel.handleCellClick(data: item) {[weak self] success, message in
            guard let self = self else { return }
            
            if !success && message == "permission" {
                showAlertForAskPhotoPermisson()
                return
            }
            
            self.displayAlert(with: .get(.success), message: message, actions: [UIAlertAction(title: .get(.ok), style: .default, handler: nil)])
        }
    }
}

private extension CustomShareViewController {
    private func showAlertForAskPhotoPermisson() {
        let actionSheet = UIAlertController(title: "", message: .get(.photosask), preferredStyle: .alert)
        let selectPhotosAction = UIAlertAction(title: .get(.photosselected), style: .default) { _ in
            // Show limited library picker
            if #available(iOS 14, *) {
//                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) //just hang
                
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            } else {
                // Fallback on earlier versions
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: .get(.photosaccessall), style: .default) { _ in
            // Open app privacy settings
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: .get(.cancel), style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        DispatchQueue.main.async { self.present(actionSheet, animated: true) }
    }
}
