import UIKit
import KipasKipasShared
import KipasKipasDirectMessage
import KipasKipasPaymentInAppPurchase

protocol CoinPurchaseViewDelegate: AnyObject {
    func didTapHistoryButton()
    func didTapBuyNow(product id: String)
}


class CoinPurchaseView: UIView {
     
    public let amountL = UILabel()
    let tableView = UITableView()
    weak var delegate: CoinPurchaseViewDelegate?
    private let CoinPurchaseViewCellID = "CoinPurchaseViewCellID"
    var coinProducts: [RemoteCoinPurchaseProductData] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var coinInApp: [InAppPurchaseProduct] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    lazy var historyButton: UIButton = {
        let button = UIButton()
        button.setImage(.get(.icHistoryBlack), for: UIControl.State())
                button.contentMode = .center
                button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.addTarget(self, action: #selector(handleDidTapHistoryButton), for: .touchUpInside)
        return button
    }()
    
    var selectedCoinProductId: String? = nil
    
    public var isPurchaseing = false {
        didSet {
            self.tableView.reloadData()
        }
    }
     
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureUI(){ 
        let topTitleL = UILabel()
        topTitleL.text = "Saldo koin"
        topTitleL.textColor = .black
        topTitleL.font = .roboto(.bold, size: 18)
        addSubview(topTitleL)
        
        topTitleL.anchors.top.pin(inset: 28)
        topTitleL.anchors.centerX.align()
        
        let amountView = UIView()
        addSubview(amountView)
        amountView.anchors.top.equal(topTitleL.anchors.bottom,constant: 4)
        amountView.anchors.centerX.align()
        amountView.anchors.height.equal(55)
        
        let iconImgV = UIImageView()
        iconImgV.image =  .set("ic-balance-midCoin")
        amountView.addSubview(iconImgV)
        iconImgV.anchors.width.equal(30)
        iconImgV.anchors.height.equal(30)
        iconImgV.anchors.leading.pin()
        iconImgV.anchors.bottom.pin(inset: 12)
        
//        let coin = KKCache.common.readInteger(key: .coin) ?? 0
        amountL.text = "-"
        amountL.textColor = .black
        amountL.font = .roboto(.bold, size: 44)
        amountView.addSubview(amountL)
        amountL.anchors.trailing.pin()
        amountL.anchors.edges.pin(axis:.vertical)
        amountL.anchors.leading.equal(iconImgV.anchors.trailing, constant: 6)
        
        let lineL = UILabel()
        lineL.backgroundColor = UIColor(hexString: "#E9E9E9")
        addSubview(lineL)
        
        lineL.anchors.edges.pin(axis: .horizontal)
        lineL.anchors.height.equal(1)
        lineL.anchors.top.equal(amountView.anchors.bottom,constant: 19)
        
        addSubview(tableView)
        tableView.rowHeight = 48
        tableView.separatorStyle = .none 
        tableView.register(CoinPurchaseViewCell.self, forCellReuseIdentifier: CoinPurchaseViewCellID)
        tableView.dataSource = self
        tableView.anchors.top.equal(lineL.anchors.bottom,constant: 3)
        tableView.anchors.edges.pin(insets: 18, axis: .horizontal)
        tableView.anchors.bottom.pin(inset: 20)
        tableView.tableHeaderView = getTableHeader()
    }
    
    func getTableHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 29) )
        let titleL = UILabel()
        titleL.text = "Beli koin"
        titleL.textColor = .black
        titleL.font = .roboto(.regular, size: 12)
        header.addSubview(titleL)
        titleL.anchors.top.pin(inset: 12)
        titleL.anchors.leading.pin()
        return header
    }
    
    @objc private func handleDidTapHistoryButton() {
        delegate?.didTapHistoryButton()
    }
    
}


extension CoinPurchaseView :UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinPurchaseViewCellID, for: indexPath) as! CoinPurchaseViewCell
        let data = coinProducts[indexPath.row]
        cell.configCellWith(data)
        
        var valid = coinInApp.contains(where: { $0.productIdentifier == data.storeProductId })
        cell.isUserInteractionEnabled = valid
           cell.configBtnState(valid)
        if isPurchaseing  {
            valid = false
            cell.configBtnState(valid)
            if data.storeProductId == selectedCoinProductId {
                cell.configBtnPurchaseing()
            } 
        }
        
        cell.btnClicked = { [weak self] (productId) in
             print("productId = \(productId)")
            self?.selectedCoinProductId = productId
            self?.isPurchaseing = true
            
            self?.delegate?.didTapBuyNow(product: productId)
        }
        
        return cell
    }
    
}
