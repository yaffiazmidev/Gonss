import Foundation
import KipasKipasDirectMessage
import UIKit

  
class CoinPurchaseViewCell:UITableViewCell{
    let coinImageV = UIImageView()
    let titleL = UILabel()
    let button = UIButton()
    var coinProductId: String? = nil
    
    var btnClicked: ((String) -> Void)?
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    func setupCell(){
        backgroundColor = .clear
        self.selectionStyle = .none
        coinImageV.image = .set("ic-balance-midCoin")
        contentView.addSubview(coinImageV)
        coinImageV.anchors.width.equal(20)
        coinImageV.anchors.height.equal(20)
        coinImageV.anchors.leading.pin(inset: 0)
        coinImageV.anchors.centerY.align()
         
        
        titleL.text = "16500 koin"
        titleL.font = .roboto(.medium, size: 14)
        titleL.textColor = .black
        contentView.addSubview(titleL)
        titleL.anchors.leading.spacing(10, to: coinImageV.anchors.trailing)
        titleL.anchors.centerY.align()
        
        button.setTitle("$249.00")
        button.layer.cornerRadius = 4
        button.backgroundColor  = .watermelon
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .roboto(.medium, size: 12)
        contentView.addSubview(button)
        button.anchors.centerY.align()
        button.anchors.trailing.pin()
        button.anchors.height.equal(28)
        button.anchors.width.equal(96)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
      
    }
    
    @objc func buttonAction(){
        if let productId = coinProductId {
            btnClicked?(productId)
        }
    }
    
    func configCellWith(_ product:RemoteCoinPurchaseProductData){
        titleL.text =  product.description
        button.setTitle( format(double: product.price ?? 0) )
        coinProductId = product.storeProductId 
    }
    
    func configBtnState(_ enable: Bool){
        button.backgroundColor  = enable ? .watermelon : .softPeach
    }
    
    func configBtnPurchaseing(){
        button.backgroundColor  = UIColor(hexString: "#E6E6E6")
    }
    
    
    private func format(double: Double) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.init(identifier: "ID-id")
        formatter.numberStyle = .currency
        if let formatted = formatter.string(from: double as NSNumber) {
            return "\(formatted)"
        }
        return nil
    }
}
