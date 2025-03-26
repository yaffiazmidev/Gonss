import UIKit
import KipasKipasNetworking
import CoreData
import CoreLocation

final class LocationDonationController: UIViewController {
    
    private var locations: [LocationDonationItem] = [] {
        didSet { tableView.reloadData() }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Pilih filter lokasi"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private lazy var closeButton: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        
        let closeIcon = UIImageView()
        closeIcon.frame = CGRect(x: 6, y: 6, width: 20, height: 20)
        closeIcon.contentMode = .scaleAspectFit
        closeIcon.image = UIImage(named: "iconClose")
        view.addSubview(closeIcon)
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.refreshControl = refreshControl
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.estimatedRowHeight = UITableView.automaticDimension
        view.separatorStyle = .none
        return view
    }()
    
    private var filterCache: FilterDonationTemporaryStore? {
        get { return FilterDonationCache().getFilterDonations() }
        set {
            if let value = newValue {
                saveFilter(value: value)
            }
        }
    }
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let delegate: LocationDonationViewControllerDelegate
    
    private let selectByCurrentLocation: ((_ long: Double?, _ lat: Double?) -> Void)
    private let selectByProvinceId: ((LocationDonationItem) -> Void)
    private let selectAllLocation: (() -> Void)
    
    init(
        delegate: LocationDonationViewControllerDelegate,
        selectByCurrentLocation: @escaping (_ long: Double?, _ lat: Double?) -> Void,
        selectByProvinceId: @escaping (LocationDonationItem) -> Void,
        selectAllLocation: @escaping () -> Void
    ) {
        self.delegate = delegate
        self.selectByCurrentLocation = selectByCurrentLocation
        self.selectByProvinceId = selectByProvinceId
        self.selectAllLocation = selectAllLocation
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        requestUserLocation()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCustomCell(LocationDonationCell.self)
        
        view.addSubview(titleLabel)
        view.addSubview(closeButton)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(equalToConstant: 16),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            
            tableView.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        closeButton.onTap { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true)
        }
    }
    
    @objc private func refresh() {
        delegate.didRequestLocationDonation(request: .init(size: 50))
    }
    
    func requestUserLocation() {
        LocationManager.shared.getCurrentReverseGeoCodedLocation { [weak self] location, placemark, error in
            guard let self = self else { return }
            
            if error != nil {
                self.showDeniedLocationAuthorizationAlert()
                return
            }
            
            let lat = location?.coordinate.latitude.magnitude
            let long = location?.coordinate.longitude.magnitude
            let address = "\(placemark?.subThoroughfare ?? "") \(placemark?.thoroughfare ?? ""), \(placemark?.locality ?? ""), \(placemark?.administrativeArea ?? "") \(placemark?.postalCode ?? ""), \(placemark?.country ?? "")"
          
            self.filterCache = .init(
                categoryId: filterCache?.categoryId,
                longitude: long,
                latitude: lat,
                provinceId: filterCache?.provinceId,
                name: address
            )
        }
    }
    
    func saveFilter(value: FilterDonationTemporaryStore) {
        FilterDonationCache.instance.saveFilterDonations(value: value)
    }
    
    private func showDeniedLocationAuthorizationAlert() {
        let alertController = UIAlertController(
            title: "Akses lokasi dibutuhkan",
            message: "Silahkan aktifkan permintaan lokasi di Pengaturan aplikasi",
            preferredStyle: UIAlertController.Style.alert
        )
        
        let okAction = UIAlertAction(title: "Oke", style: .default, handler: { [weak self] (cAlertAction) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            self?.dismiss(animated: false)
        })
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
extension LocationDonationController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCustomCell(with: LocationDonationCell.self, indexPath: indexPath)
        cell.locationLabel.text = locations[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let location = locations[indexPath.row]
              
        if location.isAllLocation {
            filterCache = .init(
                categoryId: filterCache?.categoryId,
                name: location.name
            )
            selectAllLocation()
            
        } else if location.isCurrentLocation {
            filterCache?.provinceId = nil
            selectByCurrentLocation(filterCache?.longitude, filterCache?.latitude)
            
        } else {
            filterCache = .init(
                categoryId: filterCache?.categoryId,
                provinceId: location.id,
                name: location.name
            )
            selectByProvinceId(location)
        }
        
        dismiss(animated: true)
    }
}

extension LocationDonationController: LocationDonationView, LocationDonationLoadingView {
    
    func display(_ viewModel: LocationDonationViewModel) {
        locations = viewModel.items
    }
    
    func display(_ viewModel: LocationDonationLoadingViewModel) {
        if viewModel.isLoading {
            tableView.refreshControl?.beginRefreshing()
        } else {
            tableView.refreshControl?.endRefreshing()
        }
    }
}

