//
//  LocalRankDonationController.swift
//  KipasKipas
//
//  Created by Muhammad Noor on 22/09/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import Kingfisher
import KipasKipasShared

protocol ILocalRankDonationController: AnyObject {
    func display(localRanks: [LocalRankItem])
    func displayError(message: String)
}

class LocalRankDonationController: UIViewController {
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.allowsMultipleSelection = false
        table.isMultipleTouchEnabled = false
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.allowsSelection = false
        table.estimatedRowHeight = UITableView.automaticDimension
        table.showsVerticalScrollIndicator = false
        table.tableHeaderView = UIView()
        table.delegate = self
        table.dataSource = self
        table.accessibilityIdentifier = "tableView-LocalRanksDonations"
        table.register(LocalRankDonationCell.self, forCellReuseIdentifier: "cellId")
        return table
    }()
    
    private var data: [LocalRankItem] = []
    private var id: String?
    
    var interactor: ILocalRankDonationInteractor!
    var router: ILocalRankDonationRouter!
    
    init(id: String) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactor.requestLocalRank(id: self.id ?? "", requestPage: 0)
        setupView()
    }
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

extension LocalRankDonationController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! LocalRankDonationCell
        let validData = self.data[indexPath.row]
        cell.nameLabel.text = validData.isShowBadge ? validData.name : "Orang Dermawan"
        cell.priceLabel.text = validData.totalDonation.toMoney()
        cell.rank = validData.localRank
        if validData.isShowBadge {
            
            //cell.profileImageView.kf.indicatorType = .activity
            //cell.profileImageView.kf.setImage(with: URL(string: validData.photo), placeholder: UIImage.defaultProfileImageCircle)

            if(validData.photo == ""){
                cell.profileImageView.image = UIImage.defaultProfileImageCircle
            } else {
                cell.profileImageView.loadImage(at: validData.photo, .w100)
            }
            
        } else {
            cell.profileImageView.image = .anonimProfilePhoto
        }
        
        cell.verifyIcon.isHidden = validData.isVerified == false
        return cell
    }
}

extension LocalRankDonationController: ILocalRankDonationController {
    
    func display(localRanks: [LocalRankItem]) {
        self.data = localRanks
        tableView.reloadData()
    }
    
    func displayError(message: String) {
    
    }
}
