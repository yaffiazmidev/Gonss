//
//  TimelineViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//

import UIKit

struct TimelineItem {
    var isNews: Bool
}

class TimelineViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let timelines: [TimelineItem] = [
        TimelineItem(isNews: true),
        TimelineItem(isNews: false),
        TimelineItem(isNews: false),
        TimelineItem(isNews: true),
        TimelineItem(isNews: false),
        TimelineItem(isNews: true),
        TimelineItem(isNews: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    func setupTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: "TimelineNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelineNewsTableViewCell")
        tableView.register(UINib(nibName: "TimelinePaymentTableViewCell", bundle: nil), forCellReuseIdentifier: "TimelinePaymentTableViewCell")
    }

}

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension TimelineViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if timelines[indexPath.row].isNews {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineNewsTableViewCell", for: indexPath) as! TimelineNewsTableViewCell
            cell.horizontalLineView.isHidden = indexPath.row == timelines.count - 1
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimelinePaymentTableViewCell", for: indexPath) as! TimelinePaymentTableViewCell
            cell.horizontalLineView.isHidden = indexPath.row == timelines.count - 1
            return cell
        }
    }
}
