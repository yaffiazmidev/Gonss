//
//  DiamondWithdrawalHistoryView.swift
//  KipasKipasDirectMessageUI
//
//  Created by DENAZMI on 18/08/23.
//

import UIKit
import KipasKipasDirectMessage

public protocol DiamondWithdrawalHistoryViewDelegate: AnyObject {
    func didTapDetailIcon(
        status: DiamondPurchaseStatus,
        type: DiamondActivityType,
        id: String
    )
    func loadMoreHistories()
    func pullToRefresh()
}

public class DiamondWithdrawalHistoryView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.backgroundColor = .clear
        refresh.tintColor = UIColor(hexString: "#FF4265")
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refresh
    }()
    
    weak var delegate: DiamondWithdrawalHistoryViewDelegate?
    var requestPage: Int = 0
    var totalPage: Int = 0
    var contents: [RemoteCurrencyHistoryContent] = [] {
        didSet {
            tableView.emptyView(isEmpty: contents.isEmpty, title: "Belum ada penggunaan diamond", icon: .get(.icHistoryBlack))
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
        tableView.contentInset = .init(top: 10, left: 0, bottom: 0, right: 0)
        tableView.registerNib(DiamondWithdrawalHistoryTableViewCell.self)
    }
    
    @objc private func handleRefresh() {
        delegate?.pullToRefresh()
    }
}

extension DiamondWithdrawalHistoryView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == contents.count - 1 && requestPage < totalPage {
            delegate?.loadMoreHistories()
        }
    }
}

extension DiamondWithdrawalHistoryView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DiamondWithdrawalHistoryTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(item: contents[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = contents[indexPath.row]
        
        guard let status = DiamondPurchaseStatus(rawValue: item.status ?? ""),
              let type = DiamondActivityType(rawValue: item.activityType ?? ""),
              let id = item.id else {
            return
        }
        
        delegate?.didTapDetailIcon(
            status: status,
            type: type,
            id: id
        )
    }
}
