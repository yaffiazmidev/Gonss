import UIKit
import KipasKipasDonateStuff
import KipasKipasShared

public final class DonationItemListViewController: TableListController {
    
    private let searchBar = UISearchBar()
    
    let listAdapter: DonationItemListViewAdapter
    
    init(viewAdapter: DonationItemListViewAdapter) {
        self.listAdapter = viewAdapter
        super.init()
        self.listAdapter.delegate = self
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar(
            tintColor: .night,
            backIndicator: .iconChevronLeft
        )
    }
    
    public override func viewDidLoad() {
        configureUI()
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
}

// MARK: UI
private extension DonationItemListViewController {
    func configureUI() {
        configureSearchBar()
        configureTableView()
    }
    
    func configureSearchBar() {
        searchBar.placeholder = "Cari produk donasi"
        searchBar.delegate = self
        searchBar.searchTextField.font = .roboto(.regular, size: 14)
        searchBar.searchTextField.backgroundColor = .softPeach
        searchBar.searchTextField.textColor = .gravel
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: searchBar.placeholder ?? "",
            attributes: [.foregroundColor : UIColor.gravel]
        )
        
        searchBar.setImage(.iconSearch, for: .search, state: .normal)
        searchBar.searchTextPositionAdjustment = .init(horizontal: 8, vertical: 0)
        
        navigationItem.titleView = searchBar
        searchBar.sizeToFit()
    }
    
    func configureTableView() {
        emptyMessage = "Produk tidak tersedia"
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.refreshControl = refreshControl
        tableView.contentInset.bottom = 20
        
        tableView.registerCell(DonationItemListCell.self)
    }
    
    @objc func didPullToRefresh() {
        refreshControl?.setLoading(true)
        onRefresh?()
        searchBar.text = nil
    }
}

extension DonationItemListViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        listAdapter.filter(query: searchText)
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}

// MARK: DonationItemListViewAdapterDelegate
extension DonationItemListViewController: DonationItemListViewAdapterDelegate {
    func display(sections: [TableSectionController], isLoading: Bool) {
        display(sections: sections)
        
        if !isLoading {
            refreshControl?.setLoading(false)
        }
    }
}

// MARK: ResourceLoadingView & ResourceErrorView
extension DonationItemListViewController: ResourceErrorView {
    public func display(error errorViewModel: ResourceErrorViewModel) {
        display(sections: [])
    }
}
