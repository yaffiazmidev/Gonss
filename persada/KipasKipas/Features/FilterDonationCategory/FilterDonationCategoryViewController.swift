//
//  FilterDonationCategoryViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 24/02/23.
//

import UIKit
import CoreLocation
import KipasKipasShared

protocol IFilterDonationCategoryViewController: AnyObject {
    func display(categories: [RemoteDonationCategoryData])
    func displayError(message: String)
}

protocol FilterDonationSelectionDelegate: AnyObject {
    func filterBy(provinceId: String?)
    func filterBy(longitude: Double?, latitude: Double?)
    func filterByAllLocation()
}

class FilterDonationCategoryViewController: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var closeIconContainerView: UIStackView!
    @IBOutlet weak var locationView: UIView!
    
    var handleDismiss: ((String) -> Void)?
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl(backgroundColor: .white)
        refresh.tintColor = .primary
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    var interactor: IFilterDonationCategoryInteractor!
    var router: IFilterDonationCategoryRouter!
    
    weak var delegate: FilterDonationSelectionDelegate?
    
    var categories: [RemoteDonationCategoryData] = []
    let selectedId: String
    
    private var filterCache: FilterDonationTemporaryStore? {
        let cache = FilterDonationCache()
        return cache.getFilterDonations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        interactor.requestCategory()
        
        currentLocationLabel.text = filterCache?.name ?? "SEMUA LOKASI"
        closeIconContainerView.onTap { [weak self] in
            self?.dismiss(animated: true)
        }
        
        locationView.onTap { [weak self] in
            guard let self = self else { return }
            
            self.router.locationDonation()
        }
    }
    
    init(selectedId: String = "") {
        self.selectedId = selectedId
        super.init(nibName: nil, bundle: nil)
        FilterDonationCategoryRouter.configure(controller: self)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        collectionView.registerXibCell(FilterDonationCollectionViewCell.self)
    }
    
    func filterByProvinceId(_ location: LocationDonationItem) {
        currentLocationLabel.text = location.name
        delegate?.filterBy(provinceId: location.id)
    }
    
    func filterByCoordinate(longitude: Double?, latitude: Double?) {
        currentLocationLabel.text = filterCache?.name
        delegate?.filterBy(longitude: longitude, latitude: latitude)
    }
    
    func filterByAllLocation() {
        currentLocationLabel.text = filterCache?.name
        delegate?.filterByAllLocation()
    }
    
    @objc private func handleRefresh() {
        interactor.requestPage = 0
        interactor.requestCategory()
    }
    
}

extension FilterDonationCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(FilterDonationCollectionViewCell.self, for: indexPath)
        cell.filterTitleLabel.text = categories[indexPath.item].name ?? "-"
        if indexPath.item > 0 {
            cell.filterIconImageView.loadImage(at: categories[indexPath.item].icon ?? "")
        } else {
            cell.filterIconImageView.image = UIImage(named: categories[indexPath.item].icon ?? "")
        }
        
        cell.backgroundColor = UIColor.init(hexString: categories[indexPath.item].id == selectedId ? "E7F3FF" : "F9F9F9")
        return cell
    }
}

extension FilterDonationCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let categorie = categories[indexPath.item]
        
        if let temporaryData = FilterDonationCache.instance.getFilterDonations() {
            let value = FilterDonationTemporaryStore(categoryId: categorie.id, longitude: temporaryData.longitude, latitude: temporaryData.latitude, provinceId: temporaryData.provinceId, name: temporaryData.name)
            FilterDonationCache.instance.saveFilterDonations(value: value)
        }
        
        self.handleDismiss?(self.categories[indexPath.item].id ?? "")
        self.dismiss(animated: true)
    }
}

extension FilterDonationCategoryViewController: PanModalPresentable {
    public var panScrollable: UIScrollView? {
        return collectionView
    }
    
    public var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(safeAreaInsets.top)
    }
    
    public var shortFormHeight: PanModalHeight {
        return .contentHeight(view.bounds.height * 0.4)
    }
    
    public var cornerRadius: CGFloat {
        return 16
    }
    
    func panModalDidDismiss() {
        if let cache = FilterDonationCache().getFilterDonations() {
            NotificationCenter.default
                .post(
                    name: Notification.Name("com.kipaskipas.refreshDonation"),
                    object: nil,
                    userInfo: [
                        "categoryId": cache.categoryId ?? "",
                        "longitude": cache.longitude ?? 0,
                        "latitude" : cache.latitude ?? 0,
                        "provinceId" : cache.provinceId ?? "",
                        "address" : cache.provinceId ?? ""
                    ])
        }
    }
    
    public var allowsTapToDismiss: Bool {
        return false
    }
}


extension FilterDonationCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 4, height: 45)
    }
}


extension FilterDonationCategoryViewController: IFilterDonationCategoryViewController {
    func display(categories: [RemoteDonationCategoryData]) {
        refreshControl.endRefreshing()
        self.categories = categories
        let allCategory = RemoteDonationCategoryData(id: "", icon: "ic_list_black", name: "Semua")
        self.categories.insert(allCategory, at: 0)
        collectionView.reloadData()
    }
    
    func displayError(message: String) {
        refreshControl.endRefreshing()
        collectionView.isEmptyView(categories.isEmpty, title: "Daftar kategori penggalangan dana tidak ditemukan")
        DispatchQueue.main.async {
            Toast.share.show(message: message)
        }
    }
}
