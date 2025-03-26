//
//  CoinPurchaseHistoryView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 10/08/23.
//

import UIKit
import KipasKipasDirectMessage

protocol CoinPurchaseHistoryViewDelegate: AnyObject {
    func didTapDetailIcon(
        purchaseStatus: CoinPurchaseStatus,
        purchaseType: CoinActivityType,
        id: String
    )
    func loadMoreHistories()
    func pullToRefresh()
}

public class CoinPurchaseHistoryView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = UIColor(hexString: "#FF4265")
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    weak var delegate: CoinPurchaseHistoryViewDelegate?
    
    var requestPage: Int = 0
    var totalPage: Int = 0
    var contents: [RemoteCurrencyHistoryContent] = [] {
        didSet {
            tableView.emptyView(isEmpty: contents.isEmpty, title: "Belum ada penggunaan koin", icon: .get(.icHistoryBlack))
            refreshControl.endRefreshing()
            tableView.reloadData()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.refreshControl = refreshControl
        tableView.contentInset = .init(top: 8, left: 0, bottom: 0, right: 0)
        tableView.registerNib(CoinPurchaseHistoryTableViewCell.self)
    }
    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension CoinPurchaseHistoryView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == contents.count - 1 && requestPage < totalPage {
            delegate?.loadMoreHistories()
        }
    }
}

extension CoinPurchaseHistoryView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CoinPurchaseHistoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(item: contents[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contents[indexPath.row]
        
        guard let status = CoinPurchaseStatus(rawValue: item.status ?? ""),
              let type = CoinActivityType(rawValue: item.activityType ?? ""),
              let id = item.id else {
            return
        }
        
        delegate?.didTapDetailIcon(
            purchaseStatus: status,
            purchaseType: type,
            id: id
        )
    }
}
