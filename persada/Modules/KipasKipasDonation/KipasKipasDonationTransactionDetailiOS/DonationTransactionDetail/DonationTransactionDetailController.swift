import UIKit
import KipasKipasDonationTransactionDetail

public class DonationTransactionDetailController: UIViewController {
    
    private let mainView: DonationTransactionDetailView!
    private let orderId: String
    private let groupId: String?
    
    public var orderLoader: DonationTransactionDetailOrderLoader!
    public var groupLoader: DonationTransactionDetailGroupLoader!
    
    private var orderData: DonationTransactionDetailOrderItem?
    private var groupData: [DonationGroupItem]?
    
    private var onTapPayNow: ((String?) -> Void)
    private var onTapDonateAgain: ((_ orderId: String? ,_ feedId: String?) -> Void)
    
    public struct Events {
        let onTapPayNow: (String?) -> Void
        let onTapDonateAgain: (_ orderId: String? ,_ feedId: String?) -> Void

        public init(
            onTapPayNow: @escaping (String?) -> Void,
            onTapDonateAgain: @escaping (_ orderId: String? ,_ feedId: String?) -> Void
        ) {
            self.onTapPayNow = onTapPayNow
            self.onTapDonateAgain = onTapDonateAgain
        }
    }
    
    public init(orderId: String, groupId: String? = nil, events: Events) {
        self.orderId = orderId
        self.groupId = groupId
        self.mainView = DonationTransactionDetailView()
        self.onTapPayNow = events.onTapPayNow
        self.onTapDonateAgain = events.onTapDonateAgain
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view = mainView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureActions()
        request()
    }
    
    private func request() {
        let request = DonationTransactionDetailOrderRequest(id: self.orderId)
        orderLoader.load(request: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let item):
                self.orderData = item
                configureUI()
            case .failure(let error):
                print(error)
            }
        }
        
        if groupId != nil {
            let groupRequest = DonationTransactionDetailGroupRequest(groupId: self.groupId ?? "")
            groupLoader.load(request: groupRequest) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let item):
                    self.groupData = item.donations
                    self.configureGroupUI()
                case .failure(let error):
                    print("noor error \(error)")
                }
            }
        }
    }
    
    private func configureUI() {
        DispatchQueue.main.async {
            self.mainView.codePaymentView.configure(title: "Kode Pembayaran Donasi", name: self.orderData?.noInvoice ?? "")
            self.mainView.donationView.configure(title: "Donasi", name: self.orderData?.orderDetail.donationTitle ?? "", price: (self.orderData?.amount ?? 0).toCurrency(), imageURL: self.orderData?.orderDetail.urlDonationPhoto ?? "")
            self.mainView.fundraisingView.configure(title: "Penggalang Dana", name: self.orderData?.orderDetail.initiatorName ?? "", isVerified: false)
            self.mainView.receiverView.configure(title: "Penerima", name: self.orderData?.orderDetail.buyerName ?? "")
            self.mainView.paymentMethodView.configure(title: "Metode Pembayaran", name: self.orderData?.payment.bank.rawValue ?? "")
            self.mainView.totalView.configure(nominal: (self.orderData?.amount ?? 0).toCurrency(), fee: 0.toCurrency(), total: self.orderData?.amount.toCurrency() ?? "")
            
            if self.orderData?.status ?? "" == "NEW" {
                self.mainView.payNowButton.isHidden = false
                self.mainView.donateAgainButton.isHidden = true
            } else if self.orderData?.status ?? "" == "COMPLETE" {
                self.mainView.payNowButton.isHidden = true
                self.mainView.donateAgainButton.isHidden = false
            }
        }
    }
    
    @objc private func handleTapDonateAgain() {
        onTapDonateAgain(self.orderData?.orderDetail.postDonationId, self.orderData?.orderDetail.feedId)
    }
    
    @objc private func handleTapPayNow() {
        onTapPayNow(self.orderData?.id)
    }
    
    private func configureGroupUI() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mainView.donationView.configureDonation(count: self.groupData?.count ?? 0)
            self.mainView.heightDonation = (self.groupData?.count ?? 0 ) <= 1 ? 110 : 140
            if self.groupData?.count ?? 0 <= 1 {
                self.mainView.donateAgainButton.isHidden = false
                self.mainView.payNowButton.isHidden = true
            }
        }
    }
                                      
    private func configureActions() {
        mainView.donationView.clickDonations = { [weak self] in
            guard let self = self else { return }
            let validData = self.groupData?.filter { $0.postDonationID != self.orderData?.orderDetail.postDonationId ?? "" }
            let controller = DonationTransactionGroupController(items: DonationTransactionDetailGroupItem(donations: validData ?? [], totalAmount: self.orderData?.amount ?? 0))
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true)
        }
        
        mainView.donateAgainButton.addTarget(self, action: #selector(handleTapDonateAgain), for: .touchUpInside)
        mainView.payNowButton.addTarget(self, action: #selector(handleTapPayNow), for: .touchUpInside)
    }
}
