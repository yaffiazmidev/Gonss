//
//  DonationDetailTableViewCell.swift
//  KipasKipas
//
//  Created by DENAZMI on 28/02/23.
//  Copyright © 2023 Koanba. All rights reserved.
//

import UIKit
import KipasKipasShared
import Kingfisher
import KipasKipasShared

class DonationDetailTableViewCell: UITableViewCell {

    var onTapDonationItemHistory: ((String) -> Void)?
    var onTapCollectedAmountHistory: ((String) -> Void)?
    var onTapWithdrawalHistory: ((String) -> Void)?
    
    @IBOutlet weak var donationInactiveLabel: UILabel!
    @IBOutlet weak var endsInLabel: UILabel!
    @IBOutlet weak var totalCollectionTimeLabel: UILabel!
    @IBOutlet weak var totalCollectionTimeContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var donationNowButton: UIButton!
    @IBOutlet weak var descriptionLabel: ExpandableLabel!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var verifyIcon: UIImageView!
    @IBOutlet weak var initiatorNameLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var expDateLabel: UILabel!
    @IBOutlet weak var amountCollectedLabel: UILabel!
    @IBOutlet weak var emptyActivityLabel: UILabel!
    @IBOutlet weak var donationHistoryCard: DonationHistoryCardCell!
    @IBOutlet weak var withdrawalHistoryCard: DonationHistoryCardCell!
    @IBOutlet weak var balanceWithdrawalButton: KKBaseButton!
    @IBOutlet weak var rankTableView: UITableView!
    @IBOutlet weak var heightRankTableView: NSLayoutConstraint!

    @IBOutlet weak var donationItemHistoryCard: DonationHistoryCardCell!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupTableView()
        donationItemHistoryCard.historyType = .donationItem
        donationHistoryCard.historyType = .donation
        withdrawalHistoryCard.historyType = .withdrawal
        balanceWithdrawalButton.setBackgroundColor(.sweetPink, for: .disabled)
    }
    
    private var data: [LocalRankItem] = [] {
        didSet {
            rankTableView.reloadData()
        }
    }
    var handleDetailLocalRank: (() -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupTableView() {
        rankTableView.backgroundColor = UIColor(hexString: "#320647")
        rankTableView.register(DonationDetailLocalRankCell.self, forCellReuseIdentifier: "localRankId")
        rankTableView.delegate = self
        rankTableView.dataSource = self
        rankTableView.separatorStyle = .none
        rankTableView.sectionFooterHeight = UITableView.automaticDimension
        rankTableView.sectionHeaderHeight = UITableView.automaticDimension
        rankTableView.layer.cornerRadius = 8
        rankTableView.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
    }
    
    func setupView(item: RemoteDonationDetailData?) {
        let isInitiator = item?.initiator?.id == getIdUser()
        
        verifyIcon.isHidden = item?.initiator?.isVerified == false
        titleLabel.text = item?.title ?? "-"
        descriptionLabel.text = item?.descriptionValue ?? "-"
        recipientNameLabel.text = item?.recipientName ?? "-"
        initiatorNameLabel.text = item?.initiator?.name ?? "-"
        progressBar.isHidden = item?.targetAmount == 0.0
        progressBar.progress = item?.amountCollectedPercent ?? 0.0
        
        let isActive = item?.status?.uppercased() ?? "" == "ACTIVE"
        endsInLabel.isHidden = !isActive
        expDateLabel.isHidden = !isActive
        
        if isActive {
            donationNowButton.isHidden = true
        } else {
            donationNowButton.isHidden = true
        }
        
        donationInactiveLabel.isHidden = isActive
        totalCollectionTimeContainerView.isHidden = true
        
        if let expiredDate = item?.expiredAt?.toDate() {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: Date(), to: expiredDate)
            let totalDays = components.day ?? 0
            expDateLabel.text = "\(totalDays) hari"
        }
        
        let calendar = Calendar.current
        let startDate = item?.createAt?.toDate() ?? Date()
        let endDate = item?.expiredAt?.toDate() ?? Date()
        let components = calendar.dateComponents([.month, .day], from: startDate, to: endDate)
        let totalMonth = components.month ?? 0
        let totalDays = components.day ?? 0
        
        totalCollectionTimeLabel.text  = "\(totalMonth > 0 ? "\(totalMonth) Bulan, " : "")\(totalDays) Hari"
        
        let amountCollected = item?.amountCollected?.toMoney() ?? "Rp 0"
        let amountCollectedAttribute = amountCollected.attributedText(font: .Roboto(.bold, size: 17), textColor: .primary)

        if let targetAmount = item?.targetAmount, targetAmount != 0.0 {
            let targetAmountAttribute = " / \(targetAmount.toMoney())".attributedText(font: .Roboto(.bold, size: 12), textColor: .contentGrey)
            amountCollectedAttribute.append(targetAmountAttribute)
        }
        
        amountCollectedLabel.attributedText = amountCollectedAttribute
        
        
        // MARK: Donation History
        let totalItemCollected = "\(item?.totalItemCollected ?? 0)"
        let totalItem = "/ \(item?.totalItem ?? 0)"
        let text =  totalItemCollected + " " + totalItem
        
        let customType = InteractiveLabelType.custom(pattern: totalItem)
        donationItemHistoryCard.amountLabel.enabledTypes = [customType]
        donationItemHistoryCard.amountLabel.text = text
        donationItemHistoryCard.amountLabel.customColor[customType] = .azure
        donationItemHistoryCard.amountLabel.highlightedFont = .roboto(.medium, size: 14)
        donationItemHistoryCard.isHidden = !isInitiator || item?.isDonationItem == false
        donationItemHistoryCard.onTapHistoryButton = { [weak self] in
            if let campaignId = item?.id {
                self?.onTapDonationItemHistory?(campaignId)
            }
        }
        
        donationHistoryCard.isHidden = !isInitiator
        donationHistoryCard.amountLabel.text = item?.amountCollected?.toMoney()
        donationHistoryCard.adminFeeLabel.text = item?.amountCollectedAdminFee?.toMoney()
        donationHistoryCard.progressView.progress = item?.amountCollectedPercent ?? 0
        donationHistoryCard.onTapHistoryButton = { [weak self] in
            if let campaignId = item?.id {
                self?.onTapCollectedAmountHistory?(campaignId)
            }
        }
        
        withdrawalHistoryCard.isHidden = !isInitiator
        withdrawalHistoryCard.amountLabel.text = item?.amountWithdraw?.toMoney()
        withdrawalHistoryCard.progressView.progress = item?.amountWithdrawalPercent ?? 0
        withdrawalHistoryCard.onTapHistoryButton = { [weak self] in
            if let campaignId = item?.id {
                self?.onTapWithdrawalHistory?(campaignId)
            }
        }
        
        balanceWithdrawalButton.isHidden = !isInitiator
    }
    
    func setupLocalRank(items: [LocalRankItem]) {
        self.data = items
    }
}

extension DonationDetailTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count > 5 {
            return 5
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localRankId", for: indexPath) as! DonationDetailLocalRankCell
        let validData = data[indexPath.row]
        let isShowBadge = validData.isShowBadge
        if isShowBadge {
            //cell.photoImageView.userImageView.kf.indicatorType = .activity
            //cell.photoImageView.userImageView.kf.setImage(with: URL(string: validData.photo), placeholder: UIImage.defaultProfileImageCircle)
            if(validData.photo == ""){
                cell.photoImageView.userImageView.image = UIImage.defaultProfileImageCircle
            } else {
                cell.photoImageView.userImageView.loadImage(at: validData.photo, .w140, emptyImageName: "default-profile-image")
            }
            
        } else {
            cell.photoImageView.userImageView.image = .anonimProfilePhoto
        }
        
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.photoImageView.shouldShowBadge = isShowBadge
        cell.usernameLabel.isHidden = !isShowBadge
        cell.nameLabel.text = isShowBadge ? validData.name : "Orang Dermawan"
        cell.usernameLabel.text = "@\(validData.username)"
        cell.priceLabel.text = "Berdonasi " + validData.totalDonation.toMoney()
        cell.levelBadgeLabel.text = "\(validData.levelBadge)"
        
        guard let url = URL(string: validData.urlBadge) else {
            return cell
        }
        cell.badgeImage.kf.setImage(with: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.accessibilityIdentifier = "header-rankTableView"
        headerView.backgroundColor = UIColor(hexString: "#320647")
        headerView.layer.cornerRadius = 8
        headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner] // Top right corner, Top left corner respectively
        
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 0, y: 0, width: rankTableView.frame.width, height: 26)
        titleLabel.text = "Peringkat Donasi Terbanyak"
        titleLabel.font = .Roboto(.bold, size: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.accessibilityIdentifier = "footer-rankTableView"
        footerView.backgroundColor = UIColor(hexString: "#320647")
        rankTableView.isUserInteractionEnabled = true
        footerView.layer.cornerRadius = 8
        
        let titleFooterLabel = UILabel()
        let width = 150.0
        let middleX = frame.midX - (width / 2)
        titleFooterLabel.frame = CGRect(x: middleX, y: 10, width: width, height: 30)
        titleFooterLabel.text = "Lihat Lebih Banyak"
        titleFooterLabel.font = .Roboto(.bold, size: 12)
       
        let width93Persen = tableView.frame.width * 0.93
        let spacer = UIView(frame: CGRect(x: 12, y: 40, width: width93Persen, height: 1))
        spacer.backgroundColor = .gravel
        spacer.isHidden = true
        
        if data.count == 0 {
            titleFooterLabel.textColor = .whiteSmoke
            titleFooterLabel.text = "Belum ada donasi"
            footerView.isUserInteractionEnabled = false
        } else if data.count <= 5 {
            return nil
        }
        titleFooterLabel.textColor = .white
        footerView.addSubview(titleFooterLabel)
        footerView.addSubview(spacer)
        
        footerView.onTap { [weak self] in
            guard let self = self else { return }
  
            self.handleDetailLocalRank?()
        }
        
        return footerView
    }
}
