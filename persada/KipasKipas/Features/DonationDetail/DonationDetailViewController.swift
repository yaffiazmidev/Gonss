//
//  DonationDetailViewController.swift
//  KipasKipas
//
//  Created by DENAZMI on 27/02/23.
//

import UIKit
import KipasKipasShared
import KipasKipasDonationCart
import KipasKipasDonationCartUI

protocol IDonationDetailViewController: AnyObject {
    func display(donation: RemoteDonationDetailData)
    func display(activitys: [RemoteDonationDetailActivityContent])
    func display(orders: RemoteDonationOrderExistData)
    func display(continueOrders: RemoteDonationContinueOrderData)
    func display(detailOrders: RemoteDonationOrderDetailData)
    func display(createOrders: RemoteDonationCreateOrderData)
    func display(localRanks: [LocalRankItem])
    func displayError(message: String)
}

class DonationDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var statusBarView: UIView!
    @IBOutlet weak var donationImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var donationImageHeightConstaint: NSLayoutConstraint!
    @IBOutlet weak var donateCartView: UIImageView!
    @IBOutlet weak var donateNowButton: UIButton!
    @IBOutlet weak var donateGoodsButton: UIButton!
    @IBOutlet weak var containerDonateButtonView: UIView!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    
    
    lazy var donationCartCountingView: DonationCartCountingView = {
        let view = DonationCartCountingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let optionsButton: UIButton = {
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(named: "ellipsis_v_black_bg"), for: UIControl.State())
        button.isUserInteractionEnabled = true
        return button
    }()
    
    fileprivate lazy var actionSheet : DonationActionSheet = {
        let sheet = DonationActionSheet(controller: self)
        return sheet
    }()
    
    
    var interactor: IDonationDetailInteractor!
    var router: IDonationDetailRouter!
    
    var donation: RemoteDonationDetailData?
    var activitys: [RemoteDonationDetailActivityContent] = []
    var localRanks: [LocalRankItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDonationCart()
        optionsButton.addTarget(self, action: #selector(handleTapRightBarButtonItem), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: optionsButton),
            UIBarButtonItem(customView: donationCartCountingView)
        ]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDonationCampaign), name: .updateDonationCampaign, object: nil)
        
        bindNavigationBar(icon: .get(.arrowLeftWhiteBlackBg))
        setupTableView()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setCleepsNavigationbarTransparent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    init(donationId: String, feedId: String) {
        super.init(nibName: nil, bundle: nil)
        DonationDetailRouter.configure(controller: self)
        interactor.feedId = feedId
        interactor.donationId = donationId
    }
    
    @objc private func updateDonationCampaign() {
        fetchData()
    }
    
    private func fetchData() {
        interactor.requestDonation()
        interactor.requestDonationActivity()
        interactor.requestLocalRank(requestPage: 0)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupDonateButton() {
        let isActive = donation?.status?.uppercased() ?? "" == "ACTIVE"
        let isInitiator = donation?.initiator?.id == getIdUser()
        
        containerDonateButtonView.addShadow(with: UIColor(hexString: "#000000", alpha: 0.3))
        
        if isActive {
            containerDonateButtonView.isHidden = isInitiator
            if isInitiator {
                bottomTableViewConstraint = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                bottomTableViewConstraint.isActive = true
            } else {
                bottomTableViewConstraint = tableView.bottomAnchor.constraint(equalTo: containerDonateButtonView.topAnchor)
                bottomTableViewConstraint.isActive = true
            }
        } else {
            containerDonateButtonView.isHidden = true
            bottomTableViewConstraint = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            bottomTableViewConstraint.isActive = true
        }
        
        donateCartView.onTap {[weak self] in
            guard let self = self, let data = self.donation else { return }
            guard AUTH.isLogin() else {
                self.router.presentAuthPopUp()
                return
            }
            
            self.router.presentDonateCart(data: data)
        }
        
        donateNowButton.onTap { [weak self] in
            guard let self = self else { return }
            guard AUTH.isLogin() else {
                self.router.presentAuthPopUp()
                return
            }
            self.presentInputDonation()
        }
        
        donateGoodsButton.onTap { [weak self] in
            guard let self = self else { return }
            self.router.presentDonateGoods(donationId: donation?.id ?? "")
        }
    }
    private func setCleepsNavigationbarTransparent() {
        navigationController?.navigationBar.backgroundColor = .clear
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.standardAppearance = coloredAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        tableView.registerNib(DonationDetailTableViewCell.self)
        tableView.registerNib(DonationArticleActivityTableViewCell.self)
        tableView.registerNib(DonationWithdrawActivityTableViewCell.self)
    }
    
    @objc private func handleTapRightBarButtonItem() {
        guard let id = donation?.id, let title = donation?.title, let image = donation?.medias?.first?.thumbnail?.medium, let initiatorId = donation?.initiator?.id else { return }
        actionSheet.showSheet(DonationActionSheetData(id: id, title: title, image: image, initiatorId: initiatorId))
    }
    
    private func setNavBar(title: String = "", withShadow: Bool) {
        let navLabel = UILabel()
        navLabel.attributedText = title.attributedText(font: .Roboto(.medium, size: 14))
        navigationItem.titleView = navLabel
        
        navigationController?.navigationBar.layer.masksToBounds = !withShadow
        navigationController?.navigationBar.layer.shadowColor = withShadow ? UIColor.black.cgColor : nil
        navigationController?.navigationBar.layer.shadowOpacity = withShadow ? 0.12 : 0
        navigationController?.navigationBar.layer.shadowOffset = withShadow ? CGSize(width: 0, height: 1) : .zero
        navigationController?.navigationBar.layer.shadowRadius = withShadow ? 1 : 0
    }
    
    private func presentInputDonation() {
        let vc = DonationInputAmountViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.handleCreateOrderDonation = { [weak self] amount in
            guard let self = self else { return }
            
            self.interactor.donationAmount = amount
            self.interactor.checkDonationOrderExist()
        }
        self.present(vc, animated: true)
    }
}

extension DonationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == activitys.count - 1 && interactor.requestPage < interactor.totalPage {
            interactor.requestPage += 1
            interactor.requestDonationActivity()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = 200 - (scrollView.contentOffset.y + 200)
        let h = max(0, y)
        
        donationImageHeightConstaint.constant = h
        
        let offset = scrollView.contentOffset.y / 150
        if offset > -0.5 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2) {
                    self.statusBarView.bringSubviewToFront(self.tableView)
                    self.statusBarView.alpha = 1
                    self.navigationController?.navigationBar.backgroundColor = .white
                    self.navigationController?.navigationBar.alpha = 1
                    self.bindNavigationBar()
                    self.optionsButton.setImage(UIImage(named: "iconEllipsis"), for: UIControl.State())
                    self.setNavBar(title: self.donation?.title ?? "", withShadow: true)
                    self.donationCartCountingView.withPlainStyle()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.tableView.bringSubviewToFront(self.statusBarView)
                self.statusBarView.alpha = 0
                self.navigationController?.navigationBar.backgroundColor = .clear
                self.bindNavigationBar(icon: .get(.arrowLeftWhiteBlackBg))
                self.optionsButton.setImage(UIImage(named: "ellipsis_v_black_bg"), for: UIControl.State())
                self.setNavBar(withShadow: false)
                self.donationCartCountingView.withDefaultStyle()
            }
        }
    }
}

extension DonationDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : activitys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section  == 0 {
            let cell = tableView.dequeueReusableCell(DonationDetailTableViewCell.self, for: indexPath)
            cell.setupView(item: donation)
            cell.emptyActivityLabel.isHidden = !activitys.isEmpty
            cell.onTapCollectedAmountHistory = { [weak self] in
                self?.router.goToDonationHistory(campaignId: $0)
            }
            cell.onTapWithdrawalHistory = { [weak self] in
                self?.router.goToWithdrawalHistory(campaignId: $0)
            }
            cell.onTapDonationItemHistory = { [weak self] in
                self?.router.goToDonationItemHistory(campaignId: $0)
            }
            
            cell.balanceWithdrawalButton.onTap { [weak self] in
                guard let self = self else { return }
                self.router.presentWithdrawalPage(amountAvailable: self.donation?.amountAvailable ?? 0, campaignId: self.donation?.id ?? "")
            }
            
            
            cell.handleDetailLocalRank = { [weak self] in
                guard let self = self else { return }
                let id = self.interactor.donationId
                let vc = LocalRankDonationRouter.configure(id: id)
                vc.bindNavigationRightBar("Peringkat Donasi Terbanyak", false)
                let navigate = UINavigationController(rootViewController: vc)
                self.present(navigate, animated: true)
            }
            
            cell.setupLocalRank(items: localRanks)
            return cell
        } else {
            let item = activitys[indexPath.row]
            if item.type?.uppercased() ?? "" == "ARTICLE" {
                let cell = tableView.dequeueReusableCell(DonationArticleActivityTableViewCell.self, for: indexPath)
                cell.badgesView.backgroundColor = indexPath.row == 0 ? .secondary : .placeholder
                cell.createAtLabel.textColor = indexPath.row == 0 ? .secondary : .grey
                cell.horizontalLineView.isHidden = indexPath.row == activitys.count - 1
                cell.createAtLabel.text = "\(item.createAt?.toDateString(with: "dd MMM yyyy HH:mm z") ?? "")"
                cell.descriptionLabel.attributedText = item.description?.htmlToAttributedString
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(DonationWithdrawActivityTableViewCell.self, for: indexPath)
                cell.badgesView.backgroundColor = indexPath.row == 0 ? .secondary : .placeholder
                cell.createAtLabel.textColor = indexPath.row == 0 ? .secondary : .grey
                cell.horizontalLineView.isHidden = indexPath.row == activitys.count - 1
                cell.withdrawAmountLabel.text = item.amount?.toMoney()
                cell.withdrawByNameLabel.text = item.withdrawByName ?? "-"
                cell.recipientNameLabel.text = item.recipientName ?? "-"
                cell.createAtLabel.text = "\(item.createAt?.toDateString(with: "dd MMM yyyy hh:mm") ?? "") WIB"
                return cell
            }
        }
    }
}

extension DonationDetailViewController: IDonationDetailViewController {
    func display(donation: RemoteDonationDetailData) {
        self.donation = donation
        interactor.feedId = donation.feedId ?? ""
        //donationImageView.loadImage(at: donation.medias?.filter({ $0.type == "image" }).first?.url ?? "")
        donationImageView.loadImage(at: donation.medias?.filter({ $0.type == "image" }).first?.url ?? "", .w360)
        
        let isNotDonationItem = donation.isDonationItem == false
        donateGoodsButton.isHidden = isNotDonationItem
        donateNowButton.titleLabel?.text = isNotDonationItem ? "Donasi Sekarang" : "Donasi Uang"
        donateNowButton.setImage(isNotDonationItem ? nil : UIImage(named: "ic_money"), for: .normal)
        
        //tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        tableView.reloadData()
        setupDonateButton()
        loadDonationCartData()
    }
    
    func display(activitys: [RemoteDonationDetailActivityContent]) {
        self.activitys = interactor.requestPage > 0 ? self.activitys + activitys : activitys
        tableView.reloadData()
    }
    
    func display(orders: RemoteDonationOrderExistData) {
        
        if orders.isOrderExist == true {
            let vc = CustomPopUpViewController(title: "Masih ada transaksi yang belum selesai.",
                                               description: "Masih ada transaksi donasi yang belum kamu selesaikan. Lanjutkan donasi jika ingin membatalkan transaksi sebelumnya, atau pergi ke transaksi sebelumnya.",
                                               withOption: true,
                                               cancelBtnTitle: "Ke transaksi sebelumnya",
                                               okBtnTitle: "Lanjutkan donasi",
                                               isHideIcon: true,
                                               okBtnBgColor: .primary,
                                               actionStackAxis: .vertical)
            vc.handleTapOKButton = { [weak self] in
                guard let self = self else { return }
                self.interactor.continueDonationOrder()
            }
            
            vc.handleTapCancelButton = { [weak self] in
                guard let self = self else { return }
                self.interactor.requestDonationOrderDetail(id: orders.orderId ?? "")
            }
            
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true, completion: nil)
        } else {
            interactor.createDonationOrder()
        }
    }
    
    func display(continueOrders: RemoteDonationContinueOrderData) {
        guard let url = URL(string: continueOrders.redirectUrl ?? "") else {
            self.displayError(message: "Pembayaran tidak valid.")
            return
        }
        
        UIApplication.shared.open(url)
//        let paymentVC = DonationPaymentMothodViewController(redirectUrl: continueOrders.redirectUrl ?? "")
//        paymentVC.bindNavigationBar("Pembayaran")
//        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func display(detailOrders: RemoteDonationOrderDetailData) {
        guard let url = URL(string: detailOrders.orderDetail?.urlPaymentPage ?? "") else {
            self.displayError(message: "Pembayaran tidak valid.")
            return
        }
        
        UIApplication.shared.open(url)
//        let paymentVC = DonationPaymentMothodViewController(redirectUrl: detailOrders.orderDetail?.urlPaymentPage ?? "")
//        paymentVC.bindNavigationBar("Pembayaran")
//        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func display(createOrders: RemoteDonationCreateOrderData) {
        guard let url = URL(string: createOrders.redirectUrl ?? "") else {
            self.displayError(message: "Pembayaran tidak valid.")
            return
        }
        
        UIApplication.shared.open(url)
//        let paymentVC = DonationPaymentMothodViewController(redirectUrl: createOrders.redirectUrl ?? "")
//        paymentVC.bindNavigationBar("Pembayaran")
//        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    func displayError(message: String) {
        DispatchQueue.main.async {
            Toast.share.show(message: message)
        }
    }
    
    func display(localRanks: [LocalRankItem]) {
        self.localRanks = localRanks
    }
}

//MARK: Donation Cart
private extension DonationDetailViewController {
    func setupDonationCart() {
        let size: CGFloat = 40
        
        donationCartCountingView.anchor(width: size, height: size)
        donationCartCountingView.layer.cornerRadius = size / 2
        loadDonationCartData()

        donationCartCountingView.onTap {
            self.router.presentCart()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(updateDonationCartData), name: DonationCartManagerNotification.updated, object: nil)
    }

    @objc private func updateDonationCartData() {
        loadDonationCartData()
    }

    func loadDonationCartData() {
        donationCartCountingView.updateCount(with: DonationCartManager.instance.data.count)
        donationCartCountingView.updateVisibility()
        
        let asset: AssetEnum = DonationCartManager.instance.isAdded(id: donation?.feedId ?? "") ? .iconDonationCartPink : .iconDonationCartAddPink
        donateCartView.image = UIImage(named: .get(asset))?.withTintColor(.white)
    }
}
