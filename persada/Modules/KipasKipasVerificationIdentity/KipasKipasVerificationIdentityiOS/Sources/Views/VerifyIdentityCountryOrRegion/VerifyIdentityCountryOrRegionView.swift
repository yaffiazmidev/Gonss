import UIKit
import KipasKipasShared
import KipasKipasVerificationIdentity

public class VerifyIdentityCountryOrRegionView: UIView {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var regions: [String] = [] {
        didSet {
            filteredRegions = regions
            tableView.reloadData()
        }
    }
    
    var countries: [VerifyIdentityCountryItem] = [] {
        didSet {
            filteredCountries = countries
            groupCountries()
            tableView.reloadData()
        }
    }
    
    var sectionTitles = [String]()
    var groupedCountries = [String: [VerifyIdentityCountryItem]]()
    
    var filteredRegions: [String] = []
    var filteredCountries: [VerifyIdentityCountryItem] = []
    
    var didSelectedCountry: ((VerifyIdentityCountryItem) ->Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
        setupComponent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),
            bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupComponent() {
        overrideUserInterfaceStyle = .light
        configureUI()
        groupCountries()
        setupSearchTextField()
    }
}

extension VerifyIdentityCountryOrRegionView {
    
    func groupCountries() {
        groupedCountries.removeAll()
        for country in filteredCountries {
            let countryName = country.name ?? ""
            let firstLetter = String(countryName.prefix(1))
            if groupedCountries[firstLetter] != nil {
                groupedCountries[firstLetter]?.append(country)
            } else {
                groupedCountries[firstLetter] = [country]
            }
        }
        
        sectionTitles = groupedCountries.keys.sorted()
    }
    
    func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.placeholder = "Cari"
        searchTextField.addTarget(self, action: #selector(searchTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func searchTextFieldDidChange(_ textField: UITextField) {
        guard let searchText = textField.text, !searchText.isEmpty else {
            filteredRegions = regions
            filteredCountries = countries
            groupCountries()
            tableView.reloadData()
            return
        }
        
        filteredRegions = regions.filter { $0.lowercased().contains(searchText.lowercased()) }
        filteredCountries = countries.filter { $0.name?.lowercased().contains(searchText.lowercased()) == true }
        groupCountries()
        tableView.reloadData()
    }
}

extension VerifyIdentityCountryOrRegionView {
    private func configureUI() {
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerCell(VerifyIdentityCountryOrRegionTVC.self)
        tableView.registerHeader(VerifyIdentityCountryOrRegionHeaderView.self)
    }
}

extension VerifyIdentityCountryOrRegionView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + sectionTitles.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return filteredRegions.count
        } else {
            let key = sectionTitles[section - 1]
            return groupedCountries[key]?.count ?? 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VerifyIdentityCountryOrRegionTVC = tableView.dequeueReusableCell(at: indexPath)
        
        if indexPath.section == 0 {
            cell.countryLabel.text = filteredRegions[indexPath.row]
            cell.countryLabel.font = UIFont.systemFont(ofSize: 18)
        } else {
            let key = sectionTitles[indexPath.section - 1]
            cell.countryLabel.text = groupedCountries[key]?[indexPath.row].name ?? ""
            cell.countryLabel.font = UIFont.systemFont(ofSize: 18)
        }
        
        return cell
    }
}

extension VerifyIdentityCountryOrRegionView: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: VerifyIdentityCountryOrRegionHeaderView = tableView.dequeueReusableHeader()
        headerView.configure(with: section == 0 ? filteredRegions.isEmpty && filteredCountries.isEmpty ? "" : "Kamu bisa memilih" : sectionTitles[section - 1])
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedCountry: String
        if indexPath.section == 0 {
            selectedCountry = filteredRegions[indexPath.row]
        } else {
            let key = sectionTitles[indexPath.section - 1]
            selectedCountry = groupedCountries[key]?[indexPath.row].name ?? ""
            guard let country = groupedCountries[key]?[indexPath.row] else { return }
            self.didSelectedCountry?(country)
        }
        
        print("Selected country: \(selectedCountry)")
    }
}

extension VerifyIdentityCountryOrRegionView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
